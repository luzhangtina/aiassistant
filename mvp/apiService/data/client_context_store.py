class ClientContextStore:
    def __init__(self):
        self.client_context = {}

    def get_context(self, client_id):
        return self.client_context.get(client_id)

    def set_context(self, client_id, context_data):
        self.client_context[client_id] = context_data

    def update_context(self, client_id, update_data):
        if client_id in self.client_context:
            self.client_context[client_id].update(update_data)

# Instantiate the store globally
client_context_store = ClientContextStore()
