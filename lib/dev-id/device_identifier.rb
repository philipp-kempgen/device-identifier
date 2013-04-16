require 'dev-id/binary_address'
require 'scanf'

module ::DevId
	
	# Model for a device identifier.
	#
	class DeviceIdentifier < BinaryAddress
		
		validates_length_of   :raw, :minimum => 1, :allow_blank => false, :allow_nil => true
		
	end
end

