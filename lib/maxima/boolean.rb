module Maxima
  class Boolean

    TRUE_REGEX = /\s*true\s*/i

    def self.parse(string)
      !!(TRUE_REGEX =~ string)
    rescue
      nil
    end
  end
end
