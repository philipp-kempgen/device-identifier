require 'dev-id'
require 'active_model'

module ::DevId
	
	# @private
	class BasicActiveModel
		extend  ::ActiveModel::Naming
		include ::ActiveModel::Validations
		include ::ActiveModel::MassAssignmentSecurity
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
				attributes = sanitize_for_mass_assignment( attributes, options[:as] || :default )
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

