require 'dev-id/device_identifier'
require 'dev-id/binary_address'

module ::DevId
	
	# Model for a MAC address.
	#
	# 6 bytes.
	#
	class MacAddress < DeviceIdentifier
		
		validates_length_of :raw, :is => 6
		
		# Default options for conversion to ASCII in the `pretty`
		# method.
		DEFAULT_TO_PRETTY_OPTS = {
			:sep => ':',  # typically ":" or "-" or ""
			:upcase => true,
		}.freeze
		
		# Whether the MAC address is a multicast address.
		#
		def multicast?
			return nil  if ! valid?
			return (raw.getbyte(0).to_i % 2) != 0
		end
		
		# Whether the MAC address is the "null" address (6 NULL
		# bytes).
		#
		def null?
			return nil  if ! valid?
			return raw == (?\0.force_encoding( ::Encoding::ASCII_8BIT ) * 6)
		end
		
		# Pretty ASCII representation.
		#
		def pretty( opts = nil )
			return nil  if ! valid?
			opts = DEFAULT_TO_PRETTY_OPTS.merge( opts || {} )
			return ascii( opts )
		end
		
		# The OUI (vendor part) as a raw string.
		#
		def oui_raw
			return nil  if ! valid?
			return raw.byteslice( 0, 3 )
		end
		
		# `to_s` is an alias for `pretty`.
		#
		def to_s( opts = nil )
			pretty( opts )
		end
		
	end
end

module ::DevId
	
	# Model for a partial MAC address.
	#
	class MacAddressPartial < BinaryAddress
	end
end

module ::DevId
	
	# Model for the OUI (vendor part) of a MAC address.
	#
	# 3 bytes.
	#
	class MacAddressOui < MacAddressPartial
		
		validates_length_of :raw, :is => 3
		
	end
end

