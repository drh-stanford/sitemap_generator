module SitemapGenerator
  module Utilities
    extend self

    # Copy templates/sitemap.rb to config if not there yet.
    def install_sitemap_rb(verbose=false)
      if File.exist?(SitemapGenerator.app.root + 'config/sitemap.rb')
        puts "already exists: config/sitemap.rb, file not copied" if verbose
      else
        FileUtils.cp(
          SitemapGenerator.templates.template_path(:sitemap_sample),
          SitemapGenerator.app.root + 'config/sitemap.rb')
        puts "created: config/sitemap.rb" if verbose
      end
    end

    # Remove config/sitemap.rb if exists.
    def uninstall_sitemap_rb
      if File.exist?(SitemapGenerator.app.root + 'config/sitemap.rb')
        File.rm(SitemapGenerator.app.root + 'config/sitemap.rb')
      end
    end

    # Clean sitemap files in output directory.
    def clean_files
      FileUtils.rm(Dir[SitemapGenerator.app.root + 'public/sitemap*.xml.gz'])
    end

    # Validate all keys in a hash match *valid keys, raising ArgumentError on a
    # mismatch. Note that keys are NOT treated indifferently, meaning if you use
    # strings for keys but assert symbols as keys, this will fail.
    def assert_valid_keys(hash, *valid_keys)
      unknown_keys = hash.keys - [valid_keys].flatten
      raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
    end

    # Return a new hash with all keys converted to symbols, as long as
    # they respond to +to_sym+.
    def symbolize_keys(hash)
      symbolize_keys!(hash.dup)
    end

    # Destructively convert all keys to symbols, as long as they respond
    # to +to_sym+.
    def symbolize_keys!(hash)
      hash.keys.each do |key|
        hash[(key.to_sym rescue key) || key] = hash.delete(key)
      end
      hash
    end

    # Rounds the float with the specified precision.
    #
    #   x = 1.337
    #   x.round    # => 1
    #   x.round(1) # => 1.3
    #   x.round(2) # => 1.34
    def round(float, precision = nil)
      if precision
        magnitude = 10.0 ** precision
        (float * magnitude).round / magnitude
      else
        float.round
      end
    end

    # Allows for reverse merging two hashes where the keys in the calling hash take precedence over those
    # in the <tt>other_hash</tt>. This is particularly useful for initializing an option hash with default values:
    #
    #   def setup(options = {})
    #     options.reverse_merge! :size => 25, :velocity => 10
    #   end
    #
    # Using <tt>merge</tt>, the above example would look as follows:
    #
    #   def setup(options = {})
    #     { :size => 25, :velocity => 10 }.merge(options)
    #   end
    #
    # The default <tt>:size</tt> and <tt>:velocity</tt> are only set if the +options+ hash passed in doesn't already
    # have the respective key.
    def reverse_merge(hash, other_hash)
      other_hash.merge(hash)
    end

    # Performs the opposite of <tt>merge</tt>, with the keys and values from the first hash taking precedence over the second.
    # Modifies the receiver in place.
    def reverse_merge!(hash, other_hash)
      hash.merge!( other_hash ){|k,o,n| o }
    end

    # An object is blank if it's false, empty, or a whitespace string.
    # For example, "", "   ", +nil+, [], and {} are blank.
    #
    # This simplifies:
    #
    #   if !address.nil? && !address.empty?
    #
    # ...to:
    #
    #   if !address.blank?
    def blank?(object)
      case object
      when NilClass, FalseClass
        true
      when TrueClass, Numeric
        false
      when String
        object !~ /\S/
      when Hash, Array
        object.empty?
      when Object
        respond_to?(:empty?) ? empty? : !object
      end
    end

    # An object is present if it's not blank.
    def present?(object)
      !blank?(object)
    end

    # Sets $VERBOSE for the duration of the block and back to its original value afterwards.
    def with_warnings(flag)
      old_verbose, $VERBOSE = $VERBOSE, flag
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end
