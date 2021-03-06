module Workers
  class WorkersError < RuntimeError; end
  class UnknownEventError < WorkersError; end
  class JoinError < WorkersError; end
  class FailedTaskError < WorkersError; end
  class InvalidStateError < WorkersError; end
  class MaxTriesError < WorkersError; end
  class MissingCallbackError < WorkersError; end
  class PoolSizeError < WorkersError; end
end