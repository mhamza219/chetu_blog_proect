class BaseService:
    """
    Abstract Base Class for all Python Services in this Framework.
    Every service should inherit from BaseService and implement run(payload).
    """

    def __init__(self, payload=None):
        self.payload = payload or {}

    def run(self):
        raise NotImplementedError("Subclasses must implement the run method.")
