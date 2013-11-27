#require 'dev-id'  # for DevId
require 'active_model'  # for ActiveModel (from the "activemodel" gem)
#if ! ::ActiveModel.const_defined?( :MassAssignmentSecurity )
#	# ActiveModel::MassAssignmentSecurity is no longer part of the
#	# "activemodel" gem as of version 4, but went into the
#	# "protected_attributes" gem.
#	begin
#		require 'protected_attributes'
#	rescue ::LoadError => e
#		STDERR.puts "------------------------------------------------------------"
#		STDERR.puts "#{e.message} (#{e.class.name})"
#		STDERR.puts (e.backtrace || []).reject{|l| l.match( %r{ /lib/rake/ }x )}.map{|l| "  #{l}"}
#		STDERR.puts "------------------------------------------------------------"
#		STDERR.puts "For ActiveModel >= 4 please add the \"protected_attributes\" gem to your bundle."
#		STDERR.puts "  ActiveModel version: #{::ActiveModel::VERSION::STRING}"
#		STDERR.puts "------------------------------------------------------------"
#	end
#end

module ::DevId
	
	# @private
	class BasicActiveModel
		extend  ::ActiveModel::Naming
		include ::ActiveModel::Validations
		
		if ::ActiveModel::VERSION::MAJOR <= 3
			include ::ActiveModel::MassAssignmentSecurity
		else
			include ::ActiveModel::ForbiddenAttributesProtection
		end
		
		include ::ActiveModel::Conversion
	#	extend  ::ActiveModel::Callbacks
		
		validate :before, :do_before_validation
		
		def initialize( attrs={} )
			assign_attributes( attrs )
		end
		
		# see `activerecord/lib/active_record/attribute_assignment.rb`
		def assign_attributes( new_attributes, options={} )
			return unless new_attributes.present?
			
			attributes = new_attributes.stringify_keys
			
			unless options[:without_protection]
				if ::ActiveModel::VERSION::MAJOR <= 3
					attributes = sanitize_for_mass_assignment( attributes, options[:as] || :default )
				else
					attributes = sanitize_for_mass_assignment( attributes )
				end
			end
			
			attributes.each { |k, v|
				#setter_name = :"#{k}="
				#send( setter_name, v )  if respond_to?( setter_name )
				send( :"#{k}=", v )
			}
			
			#self
			nil
		end
		
		def persisted?
			false
		end
		
		def do_before_validation
			@errors.clear
			before_validation()
		end
		
		def before_validation
			# override in sub-classes
		end
	end
	
	# @private
	class Base < BasicActiveModel
	end
	
end

