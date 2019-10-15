module Kan
  module Plugins
    module Roles
      def self.included(base)
        base.extend(ClassMethods)
        base.applicable_checklist << -> (*args) { base.valid_role?(*args) }
      end

      module ClassMethods
        DEFAULT_ROLE_NAME = :base
        DEFAULT_ROLE_BLOCK = proc { true }

        def role(role_name, object = nil, &block)
          @role_name = role_name
          @role_block = object ? make_callable(object) : block
        end

        def role_name
          @role_name || DEFAULT_ROLE_NAME
        end

        def role_block
          @role_block || DEFAULT_ROLE_BLOCK
        end

        def valid_role?(*args)
          role_block.call(*args)
        end

        private

        def make_callable(object)
          callable_object = object.is_a?(Class) ? object.new : object

          return callable_object if callable_object.respond_to? :call

          raise InvalidRoleObjectError.new "role object #{object} does not support #call method"
        end
      end
    end
  end
end
