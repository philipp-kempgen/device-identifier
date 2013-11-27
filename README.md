# Device identifier models

Models for device identifiers, e.g. MAC addresses and other identifiers for VoIP phones.

Rationale:

- Hard-phones have an Ethernet MAC address.
- Soft-phones don't. They have/need some sort of identification string
  (any sequence of bytes).
- Soft-phones may use UUIDs as identifiers.
- All of them are device identifiers, with the MAC address resp. UUID being sub-classes.

Author: Philipp Kempgen, [http://kempgen.net](http://kempgen.net)


## Usage

	require 'dev-id'
	
	m = DevId::MacAddress.from_hex ""
	m.valid?       # => false
	
	m = DevId::MacAddress.from_hex "001122aabbcc"
	m.valid?       # => true
	
	m = DevId::MacAddress.from_hex "00:11:22:aa:bb:cc"
	m.valid?       # => true
	
	m = DevId::MacAddress.from_hex "00-11-22-AA-BB-CC"
	m.valid?       # => true
	m.ascii        # => "001122aabbcc"
	m.pretty       # => "00:11:22:AA:BB:CC"
	m.to_s         # => "00:11:22:AA:BB:CC"
	m.pretty({ :sep => '-', :upcase => false })
                   # => "00-11-22-aa-bb-cc"
	m.raw          # => "\x00\x11\x22\xAA\xBB\xCC"
	m.bytes.to_a   # => [0, 17, 34, 170, 187, 204]
	m.bytesize     # => 6
	m.to_int       # => 73596058572
	m.starts_with? DevId::MacAddressOui.from_hex '00:11:22'
	               # => true
	m.starts_with? DevId::MacAddressPartial.from_hex '00:11:22:aa'
	               # => true
	
	# MacAddress specific:
	m.null?        # => false
	m.multicast?   # => false
	m.oui_raw      # => "\x00\x11\x22"


## Inheritance

The class inheritance is as follows:

- **`Base`**
	
	Base model class, providing validations etc.
	
	- **`BinaryAddress`**
		
		Model for a raw binary address.
		
		- **`DeviceIdentifier`**
			
			Model for a device identifier.
			
			- **`MacAddress`**
				
				Model for a MAC address.
			
			- **`DeviceUuid`**
				
				Model for a device identifier UUID.
		
		- **`MacAddressPartial`**
			
			Model for a partial MAC address.
			
			- **`MacAddressOui`**
				
				Model for the OUI (vendor part) of a MAC address.


## Device identifiers

There are 3 kinds of device identifiers: the generic `DeviceIdentifier`, and the more specific `MacAddress` and `DeviceUuid`.

All of them support the methods in following (amongst others):

- `bytes`
	
	The raw bytes.

- `ascii( opts = nil )`
	
	An ASCII representation (hex format).

- `to_s( opts = nil )`
	
	An ASCII representation (hex format).


## Classes


### `Base`

Includes some `ActiveModel` mix-ins (`ActiveModel::Validations` etc.).

Provides methods such as `valid?`.


### `BinaryAddress`

**Inheritance**:
`Base` >
`BinaryAddress`

Model for a raw binary address.

Includes the `::Comparable` mix-in.

Class methods:

- `self.from_raw( str )`
	
	Initializer. Creates a new object from a raw representation.

- `self.from_hex( str )`
	
	Initializer. Creates a new object from a hex representation,
	with or without "`:`" or "`-`" separators.

Instance methods:

- `bytes`
	
	The raw bytes.

- `bytesize`
	
	The number of bytes.

- `getbyte( index )`
	
	Returns one of the raw bytes as an integer.

- `byteslice( from, len = nil )`
	
	Returns a slice (sub-string) of the raw bytes.
	`from` can be an `Integer` or a `Range` – in the latter case `len` must not be specified.

- `length`
	
	Alias for `bytesize`.

- `ascii( opts = nil )`
	
	An ASCII representation (hex format).
	
	Default options are:
		
		{
			:sep     => '',     # separator, typically ":" or "-" or ""
			:upcase  => false,  # use uppercase?
		}
	
	Returns `nil` if invalid.

- `to_int`
	
	An integer representation.

- `starts_with?( other )`
	
	Whether it starts with the other `BinaryAddress`.

- `start_with?( other )`
	
	Alias for `starts_with?( other )`.


### `DeviceIdentifier`

**Inheritance**:
`Base` >
`BinaryAddress` >
`DeviceIdentifier`

Model for a device identifier.

Validates that the raw address has a minimum length of 1 byte.


### `MacAddress`

**Inheritance**:
`Base` >
`BinaryAddress` >
`DeviceIdentifier` >
`MacAddress`

Model for a MAC address.

Instance methods:

- `multicast?`
	
	If it's a multicast MAC address (integer value of first byte odd).

- `null?`
	
	If it's a null address (all 6 bytes `\x00`: `00:00:00:00:00:00`).

- `pretty( opts = nil )`

	A pretty ASCII representation (hex format).
	
	Default options are:
		
		{
			:sep     => ':',    # separator, typically ":" or "-" or ""
			:upcase  => true,   # use uppercase?
		}
	
	The default options are the same as for the inherited `ascii` method, except that the separator is "`:`" instead of "".

- `oui_raw`

	The OUI (vendor) part (first 3 bytes) in raw format.


### `DeviceUuid`

**Inheritance**:
`Base` >
`BinaryAddress` >
`DeviceIdentifier` >
`DeviceUuid`

Model for a device UUID.

Instance methods:

- `null?`
	
	If it's a null address (all bytes `\x00`: `00000000-0000-0000-0000-000000000000`).

- `pretty( opts = nil )`

	A pretty ASCII representation (hex format).
	
	Default options are:
		
		{
			:sep     => '-',    # separator, typically "-"
			:upcase  => false,  # use uppercase?
		}
	
	If the default options are used this method returns the canonical UUID representation.

- A couple of UUID specific methods (named `uuid`...).


### `MacAddressPartial`

**Inheritance**:
`Base` >
`BinaryAddress` >
`MacAddressPartial`

Model for a partial MAC address.


### `MacAddressOui`

**Inheritance**:
`Base` >
`BinaryAddress` >
`MacAddressPartial` >
`MacAddressOui`

Model for the OUI (vendor) part of a MAC address.

Validates that the raw address has a length of 3 bytes.

