module Kan
  class AbilitiesList
    def initialize(name, list)
      @name = name
      @list = list
    end

    def call(*payload, **options)
      applicable_abilities = fetch_applicable_abilities(payload)
      return applicable_abilities if options[:return_abilities]
      apply_abilities(applicable_abilities, payload)
    end

    private

    def fetch_applicable_abilities(*payload)
      @list.select { |abilities| abilities.applicable?(*payload) }
    end

    def apply_abilities(abilities, payload)
      abilities.any? { |ability| ability.ability(@name).call(*payload) }
    end
  end
end
