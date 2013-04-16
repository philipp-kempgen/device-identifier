# Device identifier models

Models for device identifiers, e.g. MAC addresses and other identifiers for VoIP phones.

Rationale:

- Hard-phones have an Ethernet MAC address.
- Soft-phones don't. They have/need some sort of identification string
  (any sequence of bytes).
- Both are device identifiers, with the MAC address being a sub-class.

Author: Philipp Kempgen, [http://kempgen.net](http://kempgen.net)


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
		
		- **`MacAddressPartial`**
			
			Model for a partial MAC address.
			
			- **`MacAddressOui`**
				
				Model for the OUI (vendor part) of a MAC address.


## Device identifiers

There are 2 kinds of device identifiers: the generic `DeviceIdentifier` and the more specific `MacAddress`.

Both support the methods in following (amongst others):

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
	
	If it's a null address (all 6 bytes \x00: 00:00:00:00:00:00).

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


