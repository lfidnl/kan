require 'logger'

module Kan
  module Abilities
    def self.included(base)
      base.extend(ClassMethods)
    end

    class InvalidRoleObjectError < StandardError; end
    class InvalidAbilityNameError < StandardError; end
    class InvalidAliasNameError < StandardError; end

    module ClassMethods
      RESERVED_NAME = :roles.freeze

      def register(*abilities, &block)
        abilities.map!(&:to_sym)
        raise InvalidAbilityNameError if abilities.include?(RESERVED_NAME)

        abilities.each do |ability|
          aliases.delete(ability)
          ability_list[ability] = block
        end
      end

      def register_alias(name, ability)
        normalized_name = name.to_sym
        normalized_ability = ability.to_sym
        raise InvalidAliasNameError if normalized_name == RESERVED_NAME

        aliases[normalized_name] = normalized_ability
      end

      def ability(name)
        normalized_name = name.to_sym
        ability = aliases.fetch(normalized_name, normalized_name)

        ability_list[ability]
      end

      def ability_list
        @ability_list ||= {}
      end

      def applicable_checklist
        @applicable_checklist ||= []
      end

      private

      def aliases
        @aliases ||= {}
      end
    end

    DEFAULT_ABILITY_BLOCK = proc { true }

    attr_reader :logger

    def initialize(options = {})
      @options = options
      @after_call_callback = options[:after_call_callback]
      @logger = @options.fetch(:logger, Logger.new(STDOUT))
    end

    def ability(name)
      normalized_name = name.to_sym
      rule = self.class.ability(normalized_name) || @options[:default_ability_block] || DEFAULT_ABILITY_BLOCK

      ->(*args) do
        result = instance_exec(args, &rule)
        @after_call_callback && @after_call_callback.call(normalized_name, args)
        result
      end
    end

    def applicable?(*args)
      self.class.applicable_checklist.all? { |checklist| checklist.call(*args) }
    end
  end
end
