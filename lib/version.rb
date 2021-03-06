module RespondTo
  module Version
    # Returns a hash representing the version.
    # The :major, :minor, and :teeny keys have their respective numbers.
    # The :string key contains a human-readable string representation of the version.
    # The :rev key will have the current revision hash.
    #
    # This method swiped from Fancy Buttons by Brandon Mathis who swiped it from Compass by Chris Eppstein who swiped it from Haml and then modified it, so some credit goes to Nathan Weizenbaum too.
    def version
      if defined?(@version)
        @version
      else
        read_version
      end
    end

    protected

    def scope(file) # :nodoc:
      File.join(File.dirname(__FILE__), '..', file)
    end

    def read_version
      require 'yaml'
      @version = YAML::load(File.read(scope('VERSION.yml')))
      @version[:teeny] = @version[:patch]
      @version[:string] = "#{@version[:major]}.#{@version[:minor]}"
      @version[:string] << ".#{@version[:patch]}" if @version[:patch]
      @version[:string] << ".#{@version[:state]}" if @version[:state]
      @version[:string] << ".#{@version[:build]}" if @version[:build]
      #if !ENV['OFFICIAL'] && r = revision
      #  @version[:string] << ".#{r[0..6]}"
      #end
      @version
    end

    def revision
      revision_from_git
    end

    def revision_from_git
      if File.exists?(scope('.git/HEAD'))
        rev = File.read(scope('.git/HEAD')).strip
        if rev =~ /^ref: (.*)$/
          rev = File.read(scope(".git/#{$1}")).strip
        end
      end
    end
  end
  extend RespondTo::Version
  def self.const_missing(const)
    # This avoid reading from disk unless the VERSION is requested.
    if const == :VERSION
      version[:string]
    else
      super
    end
  end
end

