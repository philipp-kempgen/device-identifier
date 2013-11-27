require 'dev-id/device_identifier'
require 'dev-id/binary_address'
require 'dev-id/mac_address'

module ::DevId
	
	# Model for a device UUID.
	#
	# 16 bytes.
	#
	class DeviceUuid < DeviceIdentifier
		
		validates_length_of :raw, :is => 16
		
		# Default options for conversion to ASCII in the `pretty`
		# method.
		DEFAULT_TO_PRETTY_OPTS = {
			:sep => '-',  # typically "-"
			:upcase => false,
		}.freeze
		
		UUID_VARIANT_NCS        = :ncs         # 0b0xx, reserved, NCS backward compatibility (also used for the nil UUID)
		UUID_VARIANT_RFC_4122   = :rfc4122     # 0b10x, the variant specified by RFC 4122
		UUID_VARIANT_MICROSOFT  = :microsoft   # 0b110, reserved, Microsoft backward compatibility
		UUID_VARIANT_FUTURE     = :future      # 0b111, reserved for future definition
		
		# Whether the device UUID is the "nil"/"null" address (16
		# NULL bytes).
		#
		def null?
			return nil  if ! valid?
			return raw == (?\0.force_encoding( ::Encoding::ASCII_8BIT ) * 16)
		end
		
		# Pretty ASCII representation in UUID format (8-4-4-4-12).
		#
		def pretty( opts = nil )
			return nil  if ! valid?
			opts = DEFAULT_TO_PRETTY_OPTS.merge( opts || {} )
			#return ascii( opts )
			#return ::Kernel.sprintf( '%.2x%.2x%.2x%.2x-%.2x%.2x-%.2x%.2x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x', * self.bytes )
			uuid_str = raw.unpack( 'H8H4H4H4H12' ).join( opts[:sep] )
			uuid_str = uuid_str.upcase  if opts[:upcase]
			return uuid_str
		end
		
		# Pretty ASCII representation in UUID format (8-4-4-4-12).
		#
		# This is the same as .pretty with default options
		# ({ :sep => '-', :upcase => false }) but slightly faster.
		#
		def uuid_str
			return nil  if ! valid?
			return raw.unpack( 'H8H4H4H4H12' ).join( '-' )
		end
		
		# `to_s` is an alias for `pretty`.
		#
		def to_s( opts = nil )
			pretty( opts )
		end
		
		def require_uuid_tools
			require 'uuidtools'  unless ::Module.const_defined?( :UUIDTools )
		end
		private :require_uuid_tools
		
		def uuid
			if @uuid == nil
				if ! valid?
					@uuid = false
				else
					require_uuid_tools()
					@uuid = ::UUIDTools::UUID.parse_raw( raw )
				end
			end
			@uuid
		end
		
		# Returns the UUID type (a.k.a. variant).
		#
		# Possible values:
		#   - 0b000: reserved, NCS backward compatibility (also used for the nil UUID)
		#   - 0b001:   ", mapped to 0b000
		#   - 0b010:   ", mapped to 0b000
		#   - 0b011:   ", mapped to 0b000
		#   - 0b100: the variant specified by RFC 4122
		#   - 0b101:   ", mapped to 0b100
		#   - 0b110: reserved, Microsoft backward compatibility
		#   - 0b111: reserved for future definition
		#
		def uuid_variant
			#return nil  if ! uuid
			#return uuid.variant
			
			return nil  if ! valid?
			var_raw = raw.getbyte(8) >> 5
			ret = nil
			if (var_raw >> 2) == 0
				ret = 0x000
			elsif (var_raw >> 1) == 2
				ret = 0x100
			else
				ret = var_raw
			end
			return (ret >> 6)
		end
		alias :uuid_type :uuid_variant
		
		def uuid_variant_name
			v = uuid_variant
			{
				0b100 => UUID_VARIANT_RFC_4122,
				0b000 => UUID_VARIANT_NCS,
				0b110 => UUID_VARIANT_MICROSOFT,
				0b111 => UUID_VARIANT_FUTURE,
			}[ v ]
		end
		alias :uuid_type_name :uuid_variant_name
		
		def uuid_variant_ncs?
			v = uuid_variant
			v ? (v == 0b000) : nil
		end
		alias :'uuid_type_ncs?' :'uuid_variant_ncs?'
		
		def uuid_variant_rfc4122?
			v = uuid_variant
			v ? (v == 0b100) : nil
		end
		alias :'uuid_type_rfc4122?' :'uuid_variant_rfc4122?'
		
		def uuid_variant_microsoft?
			v = uuid_variant
			v ? (v == 0b110) : nil
		end
		alias :'uuid_type_microsoft?' :'uuid_variant_microsoft?'
		
		def uuid_variant_future?
			v = uuid_variant
			v ? (v == 0b111) : nil
		end
		alias :'uuid_type_future?' :'uuid_variant_future?'
		
		# Returns the UUID sub-type (a.k.a. version).
		#
		# Possible values:
		#   - 1: time-based with unique or random host identifier
		#   - 2: DCE Security version, with embedded POSIX UIDs
		#   - 3: name-based (uses MD5 hash)
		#   - 4: random
		#   - 5: name-based (uses SHA-1 hash)
		#
		def uuid_version
			#return nil  if ! uuid
			#return nil  if ! uuid_variant_rfc4122?
			#return uuid.version
			
			return nil  if ! valid?
			return nil  if ! uuid_variant_rfc4122?
			#b6 = self.bytes.to_a[ 6 ]
			b6 = (raw || '').getbyte( 6 )
			return nil  if ! b6
			#b6.div( 16 )  # return value
			b6 >> 4  # return value
		end
		alias :uuid_sub_type :uuid_version
		
		# Returns the MAC address (lowercase, ":"-separated) used to
		# generate this UUID, or nil if a MAC address was not used.
		# Applies only to version 1 UUIDs with a given (i.e.
		# non-random) node ID.
		#
		def uuid_mac_addr
			#return nil  if ! uuid
			#return nil  if ! uuid_variant_rfc4122?
			#return uuid.mac_address.upcase
			
			return nil  if ! valid?
			return nil  if ! uuid_variant_rfc4122?
			return nil  if uuid_version != 1
			return nil  if uuid_random_node_id?
			opts = ::DevId::MacAddress::DEFAULT_TO_PRETTY_OPTS
			return self.byteslice( 10, 6 ).bytes.map{ |b| (opts[:upcase] ? '%02X' : '%02x') % [b] }.join( opts[:sep] )
		end
		
		# This method applies only to version 1 UUIDs. Checks if the
		# node ID was generated from a random number or from a MAC
		# address. Always returns `false` for UUIDs that aren't
		# version 1. This should not be confused with version 4
		# UUIDs where more than just the node ID is random.
		#
		def uuid_random_node_id?
			#return nil  if ! uuid
			#return nil  if ! uuid_variant_rfc4122?
			#return uuid.random_node_id?
			
			return nil  if ! valid?
			return nil  if ! uuid_variant_rfc4122?
			return false  if uuid_version != 1
			return ((raw.getbyte( 10 ) & 0x01) == 1)
		end
		
		# This method applies only to version 1 UUIDs. Returns the
		# timestamp used to generate this UUID.
		#
		# @return  `Time` instance   timestamp
		#
		def uuid_timestamp
			return nil  if ! uuid
			return nil  if ! uuid_variant_rfc4122?
			#return uuid.timestamp
			
			return nil  if ! valid?
			return nil  if ! uuid_variant_rfc4122?
			return nil  if uuid_version != 1
			
			tlmh = raw.unpack('Nnn')  # time_low, time_mid, time_hi_and_version
			t_utc_100_ns = tlmh[0] + (tlmh[1] << 32) + ((tlmh[2] & 0x0FFF) << 48)
			
			# Subtract offset between UUID time and Unix time.
			# UUID UTC base time is October 15, 1582 (1582-10-15 00:00:00 Z).
			# Unix UTC base time is January  1, 1970 (1970-01-01 00:00:00 Z).
			return ::Time.at(
				(t_utc_100_ns - 0x01B21DD213814000) / 10000000.0 )
		end
		
		# Returns an URI string ("`urn:uuid:`"...) for this UUID.
		#
		def uuid_to_uri
			uuid ? "urn:uuid:#{self.uuid_str}" : nil
		end
		alias :uuid_to_urn :uuid_to_uri
		
	end
end

