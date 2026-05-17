defmodule AdyenClient.CircuitBreakerTest do
  use ExUnit.Case, async: false

  # We test the circuit breaker in isolation using a local GenServer instance
  # rather than the global one (which runs in the application supervision tree).

  defp start_breaker(opts \\ []) do
    threshold = Keyword.get(opts, :failure_threshold, 3)
    timeout = Keyword.get(opts, :reset_timeout_ms, 100)

    {:ok, pid} =
      GenServer.start_link(AdyenClient.CircuitBreaker,
        failure_threshold: threshold,
        reset_timeout_ms: timeout
      )

    pid
  end

  describe "initial state" do
    test "starts in :closed state" do
      pid = start_breaker()
      assert GenServer.call(pid, :state) == :closed
    end

    test "allows requests when closed" do
      pid = start_breaker()
      assert GenServer.call(pid, :allow?) == :ok
    end
  end

  describe "failure accumulation" do
    test "opens after threshold failures" do
      pid = start_breaker(failure_threshold: 3)

      GenServer.cast(pid, :failure)
      GenServer.cast(pid, :failure)
      assert GenServer.call(pid, :state) == :closed

      GenServer.cast(pid, :failure)
      assert GenServer.call(pid, :state) == :open
    end

    test "blocks requests when open" do
      pid = start_breaker(failure_threshold: 2)

      GenServer.cast(pid, :failure)
      GenServer.cast(pid, :failure)

      assert {:error, :circuit_open} = GenServer.call(pid, :allow?)
    end

    test "single failure does not open circuit" do
      pid = start_breaker(failure_threshold: 5)
      GenServer.cast(pid, :failure)
      assert GenServer.call(pid, :state) == :closed
    end
  end

  describe "recovery" do
    test "moves to :half_open after reset timeout" do
      pid = start_breaker(failure_threshold: 2, reset_timeout_ms: 50)

      GenServer.cast(pid, :failure)
      GenServer.cast(pid, :failure)
      assert GenServer.call(pid, :state) == :open

      Process.sleep(60)
      assert GenServer.call(pid, :state) == :half_open
    end

    test "closes after success in :half_open state" do
      pid = start_breaker(failure_threshold: 2, reset_timeout_ms: 50)

      GenServer.cast(pid, :failure)
      GenServer.cast(pid, :failure)
      Process.sleep(60)

      assert GenServer.call(pid, :state) == :half_open
      GenServer.cast(pid, :success)
      assert GenServer.call(pid, :state) == :closed
    end

    test "success in :closed resets failure counter" do
      pid = start_breaker(failure_threshold: 3)

      GenServer.cast(pid, :failure)
      GenServer.cast(pid, :failure)
      GenServer.cast(pid, :success)
      GenServer.cast(pid, :failure)
      GenServer.cast(pid, :failure)

      # Only 2 failures after the reset, should still be closed
      assert GenServer.call(pid, :state) == :closed
    end
  end

  describe "allow? in half_open" do
    test "allows probe request in :half_open" do
      pid = start_breaker(failure_threshold: 2, reset_timeout_ms: 50)

      GenServer.cast(pid, :failure)
      GenServer.cast(pid, :failure)
      Process.sleep(60)

      assert :ok = GenServer.call(pid, :allow?)
    end
  end
end

defmodule AdyenClient.RateLimiterTest do
  use ExUnit.Case, async: false

  defp start_limiter(rate \\ 100, burst \\ 200) do
    {:ok, pid} =
      GenServer.start_link(AdyenClient.RateLimiter,
        rate: rate,
        burst: burst
      )

    pid
  end

  describe "token bucket" do
    test "allows requests when tokens are available" do
      pid = start_limiter(100, 200)
      # Should succeed immediately since bucket starts full
      assert :ok = GenServer.call(pid, {:acquire, 1}, 1_000)
    end

    test "allows acquiring multiple tokens at once" do
      pid = start_limiter(100, 200)
      assert :ok = GenServer.call(pid, {:acquire, 10}, 1_000)
    end

    test "allows up to burst limit immediately" do
      pid = start_limiter(10, 50)
      # Acquire 50 tokens (full burst)
      assert :ok = GenServer.call(pid, {:acquire, 50}, 1_000)
    end
  end
end
