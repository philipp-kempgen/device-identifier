require 'dev-id/base'
require 'scanf'

module ::DevId
	
	# Model for a raw binary address.
	#
	class BinaryAddress < Base
		
		include ::Comparable
		
		# The raw address.
		attr_accessor :raw
		
		def before_validation
			if raw
				raw = raw.to_s.force_encoding( ::Encoding::ASCII_8BIT )
			end
		end
		
		validates_presence_of :raw
		
		# Default options for conversion to ASCII in the `ascii`
		# method.
		DEFAULT_TO_ASCII_OPTS = {
			:sep => '',  # typically ":" or "-" or ""
			:upcase => false,
		}.freeze
		
		def bytes
			(raw || '').bytes
		end
		
		def bytesize
			(raw || '').bytesize
		end
		alias :length :bytesize
		
		def byteslice( from, len=nil )
			return nil  if ! raw
			if len
				raw.byteslice( from, len )
			else
				raw.byteslice( from )  # from can be a Fixnum or a Range
			end
		end
		alias :'[]' :'byteslice'
		
		def getbyte( idx )
			(raw || '').getbyte( idx )
		end
		
		# Construct a new instance from a raw string.
		#
		def self.from_raw( str )
			addr = self.new( :raw => str )
		end
		
		# Construct a new instance from a hex string.
		#
		def self.from_hex( str )
			addr = self.new()
			str = str.to_s.dup
			str.force_encoding( ::Encoding::ASCII_8BIT )
			str.gsub!( /[:\-]/, '' )
			raw = str.scanf( '%2X' ) { |x,| x.to_i.chr( ::Encoding::ASCII_8BIT ) }.
				join( ''.force_encoding( ::Encoding::ASCII_8BIT ) )
			addr.raw = raw
			return addr
		end
		
		# ASCII representation.
		#
		def ascii( opts = nil )
			return nil  if ! valid?
			opts = DEFAULT_TO_ASCII_OPTS.merge( opts || {} )
			return self.bytes.map{ |b| (opts[:upcase] ? '%02X' : '%02x') % [b] }.join( opts[:sep] )
		end
		
		# `to_s` is an alias for `ascii`.
		#
		def to_s( opts = nil )
			ascii( opts )
		end
		
		# If `other` is of the same class, compares the raw values.
		# Returns `nil` unless `self` and `other` have a raw address.
		# Returns `nil` if `other` is an instance of a different class.
		#
		def <=>( other )
			return nil  unless other.kind_of?( BinaryAddress )
			return nil  unless (self.raw && other.raw)
			return self.raw <=> other.raw  #OPTIMIZE ?
		end
		
		# `to_int` helps with `include?`.
		#
		# http://rhnh.net/2009/08/03/range-include-in-ruby-1-9
		#
		# Note: ActiveSupport (as of Version 3.2.1) messes with
		# Range#include?() (in
		# `lib/active_support/core_ext/range/include_range.rb`)
		# even though they say "The native Range#include? behavior
		# is untouched.", so you will have to use Range#cover?()
		# instead.
		#
		def to_int
			v = 0
			self.bytes.to_a.reverse.each_with_index { |b,i|
				vb = b
				i.times {
					vb = vb << 8
				}
				v += vb
			}
			return v
		end
		
		def ==( other )
			return super  unless other.kind_of?( BinaryAddress )
			return false  unless (self.raw && other.raw)
			return self.raw == other.raw
		end
		alias :'eql?' :'=='
		
		def starts_with?( other )
			return super  unless other.kind_of?( BinaryAddress )
			return false  unless (self.raw && other.raw)
			return self.raw.start_with?( other.raw )
		end
		alias :'start_with?' :'starts_with?'
		
		def =~( other )
			return super  unless other.kind_of?( BinaryAddress )
			return false  unless (self.raw && other.raw)
			return (self.bytesize > other.bytesize) ?
				self .raw.start_with?( other.raw ) :
				other.raw.start_with?( self .raw )
		end
		alias :'eql?' :'=='
		
		def !~( other )
			return ! (self =~ other)
		end
		
	end
end

