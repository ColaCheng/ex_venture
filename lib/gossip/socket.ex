defmodule Gossip.Socket do
  use WebSockex

  @url Application.get_env(:ex_venture, :gossip)[:url]
  @client_id Application.get_env(:ex_venture, :gossip)[:client_id]
  @client_secret Application.get_env(:ex_venture, :gossip)[:client_secret]

  alias Gossip.Socket.Implementation

  def start_link() do
    WebSockex.start_link(@url, __MODULE__, %{authenticated: false}, [name: __MODULE__])
  end

  def handle_connect(_conn, state) do
    send(self(), {:authorize})
    {:ok, state}
  end

  def handle_frame({:text, message}, state) do
    case Implementation.receive(state, message) do
      {:ok, state} ->
        {:ok, state}

      :error ->
        {:ok, state}
    end
  end

  def handle_frame(_, state) do
    {:ok, state}
  end

  def handle_cast({:broadcast, channel, message}, state) do
    message = Poison.encode!(%{
      "event" => "messages/new",
      "payload" => %{
        "channel" => channel,
        "name" => message.sender.name,
        "message" => message.message,
      },
    })

    {:reply, {:text, message}, state}
  end

  def handle_cast(_message, state) do
    {:ok, state}
  end

  def handle_info({:authorize}, state) do
    message = Poison.encode!(%{
      "event" => "authenticate",
      "payload" => %{
        "client-id" => @client_id,
        "client-secret" => @client_secret,
      },
    })

    {:reply, {:text, message}, state}
  end

  defmodule Implementation do
    require Logger

    def receive(state, message) do
      with {:ok, message} <- Poison.decode(message),
           {:ok, state} <- process(state, message) do
       {:ok, state}
      else
        _ ->
          {:ok, state}
      end
    end

    def process(state, message = %{"event" => "authenticate"}) do
      case message do
        %{"status" => "success"} ->
          Logger.info("Authenticated against Gossip", type: :gossip)

          {:ok, Map.put(state, :authenticated, true)}

        _ ->
          {:ok, state}
      end
    end

    def process(state, %{"event" => "heartbeat"}) do
      Logger.debug("Gossip heartbeat", type: :gossip)
      {:ok, state}
    end

    def process(state, message = %{"event" => "messages/broadcast"}) do
      IO.inspect message
      {:ok, state}
    end

    def process(state, _), do: {:ok, state}
  end
end
