require_relative '../../serializers/rpc/host_node_serializer'

module Agent
  class NodePlugger
    include Logging

    attr_reader :node

    # @param [HostNode] node
    def initialize(node)
      @node = node
    end

    def plugin!
      info "connect node #{node}"

      self.update_node
      self.publish_update_event
      self.send_master_info
      self.send_node_info
    rescue => exc
      error exc
    end

    def update_node
      node.set(connected: true, last_seen_at: Time.now.utc)
    end

    def publish_update_event
      node.publish_update_event
    end

    def send_node_info
      rpc_client.notify('/agent/node_info', Rpc::HostNodeSerializer.new(node).to_hash)
    end

    def send_master_info
      rpc_client.notify('/agent/master_info', {version: Server::VERSION})
    end

    private

    # @return [RpcClient]
    def rpc_client
      RpcClient.new(node.node_id, 30)
    end
  end
end
