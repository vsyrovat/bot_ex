defmodule BotEx.Handlers.ModuleHandler do
  @moduledoc """
  The base macro that all message handlers should implement
  """

  defmacro __using__(_opts) do
    quote do
      @behaviour BotEx.Behaviours.Handler

      alias BotEx.Models.Message
      alias BotEx.Helpers.UserActions
      alias BotEx.Exceptions.BehaviourError

      @doc """
      Returns a command is responsible for module processing
      """
      @impl true
      @spec get_cmd_name() :: any()
      def get_cmd_name() do
        raise(BehaviourError,
          message: "Behaviour function #{__MODULE__}.get_cmd_name/0 is not implemented!"
        )
      end

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :worker
        }
      end

      @doc """
      Asynchronous message handler
      ## Parameters
      - msg: incoming `BotEx.Models.Message` message
      - state: current state
      """
      @spec handle_call(Message.t(), reference(), any()) :: {:noreply, any()}
      def handle_call(msg, _from, state) do
        {_, new_state} = handle_message(msg, state)

        {:reply, :ok, new_state}
      end

      @impl true
      @spec handle_message(Message.t(), any()) :: any() | no_return()
      def handle_message(_a, _b) do
        raise(BehaviourError,
          message: "Behaviour function #{__MODULE__}.handle_message/2 is not implemented!"
        )
      end

      def start_link(_) do
        GenServer.start_link(__MODULE__, [])
      end

      @doc """
      Changes the current message handler
      ## Parameters
      - msg: message `BotEx.Models.Message`
      """
      @spec change_handler(Message.t()) :: true
      def change_handler(%Message{
            user_id: u_id,
            module: module,
            is_cmd: is_cmd,
            action: action,
            data: data
          }) do
        tMsg = UserActions.get_last_call(u_id)

        n_t_msg = %Message{
          tMsg
          | module: module,
            is_cmd: is_cmd,
            action: action,
            data: data
        }

        UserActions.update_last_call(u_id, n_t_msg)
      end

      defoverridable handle_message: 2
      defoverridable get_cmd_name: 0
    end
  end
end
