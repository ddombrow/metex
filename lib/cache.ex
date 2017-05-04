defmodule Cache do
    use GenServer

    @name TheCache

    def up(opts \\ []) do
         GenServer.start_link(__MODULE__, :ok, opts ++ [name: TheCache])
    end

    def down() do
         GenServer.cast(@name, :stop)
    end

    def write(key, val) do
        GenServer.call(@name, {:write, key, val})
    end

    def read(key) do
        GenServer.call(@name, {:read, key})
    end

    def delete(key) do
        GenServer.call(@name, {:delete, key})
    end

    def clear do
        GenServer.call(@name, :clear)
    end

    def exist?(key) do
        GenServer.call(@name, {:exist, key})
    end

    #callbacks

    def handle_call({:write, key, val}, _from, cache) do
        if Map.has_key?(cache, key) do
            cache = Map.put(cache, key, val)
            {:reply, :updated, cache}
        else
            cache = Map.put_new(cache, key, val)
            {:reply, :inserted, cache}
        end
    end

    def handle_call({:read, key}, _from, cache) do
        val = Map.get(cache, key, nil)
        if is_nil(val) do
            {:reply, :notfound, cache}
        else
            {:reply, val, cache}
        end
    end

    def handle_call({:delete, key}, _from, cache) do
        case Map.has_key?(cache, key) do
            true ->
                cache = Map.delete(cache, key)
                {:reply, :deleted, cache}
            false ->
                {:reply, :notfound, cache}
        end
    end

    def handle_call(:clear, _from, _cache) do
        {:reply, :ok, Map.new()}
    end

    def handle_call({:exist, key}, _from, cache) do
        {:reply, Map.has_key?(cache, key), cache}
    end

    def handle_cast(:stop, _cache) do
        {:stop, :normal, :ok}
    end

    def init(:ok) do
        {:ok, %{}}
    end
end