require 'bundler/setup'
require 'minitest/spec'
require 'minitest/autorun'
require 'dev-id'
require 'uuidtools'

DeviceUuid = DevId::DeviceUuid

describe DevId::DeviceUuid do
	
	before do
		@timestamp = Time.at( 1385541600 )
		
		# null UUID:
		@uuid_null = UUIDTools::UUID.parse( "00000000-0000-0000-0000-000000000000" )
		@dev_uuid_null = DeviceUuid.from_hex( @uuid_null.to_s )
		
		# version 1 (time-based), with "unique" host identifier:
		UUIDTools::UUID.mac_address = "00:11:22:33:44:55"
		@uuid_v1_u = UUIDTools::UUID.timestamp_create( @timestamp.dup )
		@dev_uuid_v1_u = DeviceUuid.from_hex( @uuid_v1_u.to_s )
		
		# version 1 (time-based), with random host identifier:
		UUIDTools::UUID.mac_address = nil
		@uuid_v1_r = UUIDTools::UUID.timestamp_create( @timestamp.dup )
		@dev_uuid_v1_r = DeviceUuid.from_hex( @uuid_v1_r.to_s )
		
		# version 4 (random):
		@uuid_v4 = UUIDTools::UUID.random_create()
		@dev_uuid_v4 = DeviceUuid.from_hex( @uuid_v4.to_s )
		
		# version 3 (name-based, MD5 hash):
		@uuid_v3 = UUIDTools::UUID.md5_create( UUIDTools::UUID_DNS_NAMESPACE, "example.com" )
		@dev_uuid_v3 = DeviceUuid.from_hex( @uuid_v3.to_s )
		
		# version 5 (name-based, SHA-1 hash):
		@uuid_v5 = UUIDTools::UUID.sha1_create( UUIDTools::UUID_DNS_NAMESPACE, "example.com" )
		@dev_uuid_v5 = DeviceUuid.from_hex( @uuid_v5.to_s )
	end
	
	it "should be based on valid UUIDs" do
		assert    @uuid_v1_u  .valid? , "UUID (v1, unique host) #{@uuid_v1_u.to_s.inspect} should be valid."
		assert    @uuid_v1_r  .valid? , "UUID (v1, random host) #{@uuid_v1_r.to_s.inspect} should be valid."
		assert    @uuid_v3    .valid? , "UUID (v3) #{@uuid_v3.to_s.inspect} should be valid."
		assert    @uuid_v4    .valid? , "UUID (v4) #{@uuid_v4.to_s.inspect} should be valid."
		assert    @uuid_v5    .valid? , "UUID (v5) #{@uuid_v5.to_s.inspect} should be valid."
		assert ! (@uuid_null  .valid?), "UUID (null) #{@uuid_null.to_s.inspect} should be valid."
		assert    @uuid_null.nil_uuid?, "UUID (null) #{@uuid_null.to_s.inspect} should be the null UUID."
	end
	
	it "the null UUID (UUIDTools) should not be valid" do
		assert ! (@uuid_null  .valid?), "UUID (null) #{@uuid_null.to_s.inspect} should not be valid."
		assert    @uuid_null.nil_uuid?, "UUID (null) #{@uuid_null.to_s.inspect} should be the null UUID."
	end
	
	it "should be valid" do
		assert    @dev_uuid_v1_u  .valid? , "UUID (v1, unique host) #{@dev_uuid_v1_u.to_s.inspect} should be valid."
		assert    @dev_uuid_v1_r  .valid? , "UUID (v1, random host) #{@dev_uuid_v1_r.to_s.inspect} should be valid."
		assert    @dev_uuid_v3    .valid? , "UUID (v3) #{@dev_uuid_v3.to_s.inspect} should be valid."
		assert    @dev_uuid_v4    .valid? , "UUID (v4) #{@dev_uuid_v4.to_s.inspect} should be valid."
		assert    @dev_uuid_v5    .valid? , "UUID (v5) #{@dev_uuid_v5.to_s.inspect} should be valid."
	end
	
	it "the null UUID should be valid" do
		assert   (@dev_uuid_null  .valid?), "UUID (null) #{@dev_uuid_null.to_s.inspect} should be valid."
		assert    @dev_uuid_null.null?, "UUID (null) #{@dev_uuid_null.to_s.inspect} should be the null UUID."
	end
	
	it "should be equal" do
		a = DeviceUuid.from_hex( UUIDTools::UUID.md5_create( UUIDTools::UUID_DNS_NAMESPACE, "example.com" ).to_s )
		b = DeviceUuid.from_hex( UUIDTools::UUID.md5_create( UUIDTools::UUID_DNS_NAMESPACE, "example.com" ).to_s )
		assert a == a
		assert b == b
		assert a == b
		assert b == a
		assert a.eql?( a )
		assert b.eql?( b )
		assert a.eql?( b )
		assert b.eql?( a )
	end
	
	it "should not be equal" do
		a = DeviceUuid.from_hex( UUIDTools::UUID.md5_create( UUIDTools::UUID_DNS_NAMESPACE, "example.com" ).to_s )
		b = DeviceUuid.from_hex( UUIDTools::UUID.md5_create( UUIDTools::UUID_DNS_NAMESPACE, "example.org" ).to_s )
		assert a != b
		assert b != a
		assert ! a.eql?( b )
		assert ! b.eql?( a )
	end
	
	it "should be comparable" do
		a = DeviceUuid.from_hex( UUIDTools::UUID.md5_create( UUIDTools::UUID_DNS_NAMESPACE, "example.com" ).to_s )
		b = DeviceUuid.from_hex( UUIDTools::UUID.md5_create( UUIDTools::UUID_DNS_NAMESPACE, "example.com" ).to_s )
		assert_equal 0, (a <=> a)
		assert_equal 0, (b <=> b)
		assert_equal 0, (a <=> b)
		assert_equal true, (a >= a)
		assert_equal true, (b >= b)
		assert_equal true, (a >= b)
		assert_equal true, (b >= a)
		assert_equal false, (a > a)
		assert_equal false, (b > b)
		assert_equal false, (a > b)
		assert_equal false, (b > a)
	end
	
	it "should support ASCII output" do
		assert_equal @uuid_null .hexdigest.downcase, @dev_uuid_null .ascii
		assert_equal @uuid_v1_u .hexdigest.downcase, @dev_uuid_v1_u .ascii
		assert_equal @uuid_v1_r .hexdigest.downcase, @dev_uuid_v1_r .ascii
		assert_equal @uuid_v3   .hexdigest.downcase, @dev_uuid_v3   .ascii
		assert_equal @uuid_v4   .hexdigest.downcase, @dev_uuid_v4   .ascii
		assert_equal @uuid_v5   .hexdigest.downcase, @dev_uuid_v5   .ascii
		
		assert_equal "00000000000000000000000000000000", @dev_uuid_null .ascii
		assert_equal "9073926b929f31c2abc9fad77ae3e8eb", @dev_uuid_v3   .ascii
		assert_equal "cfbff0d193755685968c48ce8b15ae17", @dev_uuid_v5   .ascii
	end
	
	it "should support pretty output" do
		assert_equal @uuid_null .to_s.downcase, @dev_uuid_null .pretty
		assert_equal @uuid_v1_u .to_s.downcase, @dev_uuid_v1_u .pretty
		assert_equal @uuid_v1_r .to_s.downcase, @dev_uuid_v1_r .pretty
		assert_equal @uuid_v3   .to_s.downcase, @dev_uuid_v3   .pretty
		assert_equal @uuid_v4   .to_s.downcase, @dev_uuid_v4   .pretty
		assert_equal @uuid_v5   .to_s.downcase, @dev_uuid_v5   .pretty
		
		assert_equal "00000000-0000-0000-0000-000000000000", @dev_uuid_null .pretty
		assert_equal "9073926b-929f-31c2-abc9-fad77ae3e8eb", @dev_uuid_v3   .pretty
		assert_equal "cfbff0d1-9375-5685-968c-48ce8b15ae17", @dev_uuid_v5   .pretty
	end
	
	it "should support .to_s" do
		assert_equal @uuid_null .to_s.downcase, @dev_uuid_null .to_s
		assert_equal @uuid_v1_u .to_s.downcase, @dev_uuid_v1_u .to_s
		assert_equal @uuid_v1_r .to_s.downcase, @dev_uuid_v1_r .to_s
		assert_equal @uuid_v3   .to_s.downcase, @dev_uuid_v3   .to_s
		assert_equal @uuid_v4   .to_s.downcase, @dev_uuid_v4   .to_s
		assert_equal @uuid_v5   .to_s.downcase, @dev_uuid_v5   .to_s
		
		assert_equal "00000000-0000-0000-0000-000000000000", @dev_uuid_null .to_s
		assert_equal "9073926b-929f-31c2-abc9-fad77ae3e8eb", @dev_uuid_v3   .to_s
		assert_equal "cfbff0d1-9375-5685-968c-48ce8b15ae17", @dev_uuid_v5   .to_s
	end
	
	it "should support pretty() with options" do
		assert_equal "9073926B-929F-31C2-ABC9-FAD77AE3E8EB", @dev_uuid_v3.pretty({ :upcase => true })
		assert_equal "CFBFF0D1-9375-5685-968C-48CE8B15AE17", @dev_uuid_v5.pretty({ :upcase => true })
	end
	
	it "should be able to return a URN URI" do
		assert_equal "urn:uuid:9073926b-929f-31c2-abc9-fad77ae3e8eb", @dev_uuid_v3   .uuid_to_uri
		assert_equal "urn:uuid:cfbff0d1-9375-5685-968c-48ce8b15ae17", @dev_uuid_v5   .uuid_to_uri
		assert_equal "urn:uuid:00000000-0000-0000-0000-000000000000", @dev_uuid_null .uuid_to_uri
		
		assert_equal @dev_uuid_v3   .uuid.to_uri, @dev_uuid_v3   .uuid_to_uri
		assert_equal @dev_uuid_v5   .uuid.to_uri, @dev_uuid_v5   .uuid_to_uri
		assert_equal @dev_uuid_null .uuid.to_uri, @dev_uuid_null .uuid_to_uri
	end
	
	it "should support a raw representation" do
		assert_equal "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", @dev_uuid_null .raw
		assert_equal "\x90\x73\x92\x6B\x92\x9F\x31\xC2\xAB\xC9\xFA\xD7\x7A\xE3\xE8\xEB", @dev_uuid_v3   .raw
		assert_equal "\xCF\xBF\xF0\xD1\x93\x75\x56\x85\x96\x8C\x48\xCE\x8B\x15\xAE\x17", @dev_uuid_v5   .raw
	end
	
	it "should support a bytesize" do
		assert_equal 16, @dev_uuid_null .bytesize
		assert_equal 16, @dev_uuid_v3   .bytesize
		assert_equal 16, @dev_uuid_v5   .bytesize
	end
	
	it "should support a bytes enumerator" do
		assert_kind_of ::Enumerator, @dev_uuid_null .bytes
		assert_kind_of ::Enumerator, @dev_uuid_v3   .bytes
		assert_kind_of ::Enumerator, @dev_uuid_v5   .bytes
	end
	
	it "should support a bytes representation" do
		assert_equal [ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ], @dev_uuid_null .bytes.to_a
		assert_equal [ 0x90, 0x73, 0x92, 0x6B, 0x92, 0x9F, 0x31, 0xC2, 0xAB, 0xC9, 0xFA, 0xD7, 0x7A, 0xE3, 0xE8, 0xEB ], @dev_uuid_v3   .bytes.to_a
		assert_equal [ 0xCF, 0xBF, 0xF0, 0xD1, 0x93, 0x75, 0x56, 0x85, 0x96, 0x8C, 0x48, 0xCE, 0x8B, 0x15, 0xAE, 0x17 ], @dev_uuid_v5   .bytes.to_a
	end
	
	it "should support .getbyte()" do
		[ 0xCF, 0xBF, 0xF0, 0xD1, 0x93, 0x75, 0x56, 0x85, 0x96, 0x8C, 0x48, 0xCE, 0x8B, 0x15, 0xAE, 0x17 ].each_with_index{ |expected, idx|
			assert_equal expected, @dev_uuid_v5.getbyte( idx ), "#{self.class.name}.from_hex( #{@dev_uuid_v5.pretty.inspect} ).getbyte( #{idx.inspect} ) should return #{expected.inspect}"
		}
		{
			16 => nil,
			-1 => 0x17,
		}.each{ |idx, expected|
			assert_equal expected, @dev_uuid_v5.getbyte( idx ), "#{self.class.name}.from_hex( #{@dev_uuid_v5.pretty.inspect} ).getbyte( #{idx.inspect} ) should return #{expected.inspect}"
		}
	end
	
	it "should be able to return a UUIDTools::UUID" do
		assert_kind_of UUIDTools::UUID, @dev_uuid_null .uuid
		assert_kind_of UUIDTools::UUID, @dev_uuid_v3   .uuid
		assert_kind_of UUIDTools::UUID, @dev_uuid_v5   .uuid
	end
	
	it "should be able to check if a random node ID was used" do
		assert ! @dev_uuid_v1_u .uuid_random_node_id?
		assert   @dev_uuid_v1_r .uuid_random_node_id?
		assert ! @dev_uuid_v3   .uuid_random_node_id?
		assert ! @dev_uuid_v4   .uuid_random_node_id?
		assert ! @dev_uuid_v5   .uuid_random_node_id?
		assert ! @dev_uuid_null .uuid_random_node_id?
		
		assert_equal !! @dev_uuid_v1_u .uuid.random_node_id?, !! @dev_uuid_v1_u .uuid_random_node_id?
		assert_equal !! @dev_uuid_v1_r .uuid.random_node_id?, !! @dev_uuid_v1_r .uuid_random_node_id?
		assert_equal !! @dev_uuid_v3   .uuid.random_node_id?, !! @dev_uuid_v3   .uuid_random_node_id?
		assert_equal !! @dev_uuid_v4   .uuid.random_node_id?, !! @dev_uuid_v4   .uuid_random_node_id?
		assert_equal !! @dev_uuid_v5   .uuid.random_node_id?, !! @dev_uuid_v5   .uuid_random_node_id?
		assert_equal !! @dev_uuid_null .uuid.random_node_id?, !! @dev_uuid_null .uuid_random_node_id?
	end
	
	it "should be able to return the UUID version" do
		assert_equal 1   , @dev_uuid_v1_u .uuid_version
		assert_equal 1   , @dev_uuid_v1_r .uuid_version
		assert_equal 3   , @dev_uuid_v3   .uuid_version
		assert_equal 4   , @dev_uuid_v4   .uuid_version
		assert_equal 5   , @dev_uuid_v5   .uuid_version
		assert_equal nil , @dev_uuid_null .uuid_version
		
		assert_equal   @dev_uuid_v1_u .uuid.version, @dev_uuid_v1_u .uuid_version
		assert_equal   @dev_uuid_v1_r .uuid.version, @dev_uuid_v1_r .uuid_version
		assert_equal   @dev_uuid_v3   .uuid.version, @dev_uuid_v3   .uuid_version
		assert_equal   @dev_uuid_v4   .uuid.version, @dev_uuid_v4   .uuid_version
		assert_equal   @dev_uuid_v5   .uuid.version, @dev_uuid_v5   .uuid_version
		assert_equal ((@dev_uuid_null .uuid.version == 0) ? nil : -1), @dev_uuid_null .uuid_version
	end
	
	it "should be able to return the UUID variant" do
		assert_equal 0b100.to_s(2).rjust(3,'0'), @dev_uuid_v1_u .uuid_variant.to_s(2).rjust(3,'0')
		assert_equal 0b100.to_s(2).rjust(3,'0'), @dev_uuid_v1_r .uuid_variant.to_s(2).rjust(3,'0')
		assert_equal 0b100.to_s(2).rjust(3,'0'), @dev_uuid_v3   .uuid_variant.to_s(2).rjust(3,'0')
		assert_equal 0b100.to_s(2).rjust(3,'0'), @dev_uuid_v4   .uuid_variant.to_s(2).rjust(3,'0')
		assert_equal 0b100.to_s(2).rjust(3,'0'), @dev_uuid_v5   .uuid_variant.to_s(2).rjust(3,'0')
		assert_equal 0b000.to_s(2).rjust(3,'0'), @dev_uuid_null .uuid_variant.to_s(2).rjust(3,'0')
		
		assert_equal @dev_uuid_v1_u .uuid.variant, @dev_uuid_v1_u .uuid_variant
		assert_equal @dev_uuid_v1_r .uuid.variant, @dev_uuid_v1_r .uuid_variant
		assert_equal @dev_uuid_v3   .uuid.variant, @dev_uuid_v3   .uuid_variant
		assert_equal @dev_uuid_v4   .uuid.variant, @dev_uuid_v4   .uuid_variant
		assert_equal @dev_uuid_v5   .uuid.variant, @dev_uuid_v5   .uuid_variant
		assert_equal @dev_uuid_null .uuid.variant, @dev_uuid_null .uuid_variant
		
		assert_equal DeviceUuid::UUID_VARIANT_RFC_4122 , @dev_uuid_v1_u .uuid_variant_name
		assert_equal DeviceUuid::UUID_VARIANT_RFC_4122 , @dev_uuid_v1_r .uuid_variant_name
		assert_equal DeviceUuid::UUID_VARIANT_RFC_4122 , @dev_uuid_v3   .uuid_variant_name
		assert_equal DeviceUuid::UUID_VARIANT_RFC_4122 , @dev_uuid_v4   .uuid_variant_name
		assert_equal DeviceUuid::UUID_VARIANT_RFC_4122 , @dev_uuid_v5   .uuid_variant_name
		assert_equal DeviceUuid::UUID_VARIANT_NCS      , @dev_uuid_null .uuid_variant_name
	end
	
	it "should be able to return the UUID timestamp" do
		assert_equal @timestamp , @dev_uuid_v1_u .uuid_timestamp
		assert_equal @timestamp , @dev_uuid_v1_r .uuid_timestamp
		assert_equal nil        , @dev_uuid_v3   .uuid_timestamp
		assert_equal nil        , @dev_uuid_v4   .uuid_timestamp
		assert_equal nil        , @dev_uuid_v5   .uuid_timestamp
		assert_equal nil        , @dev_uuid_null .uuid_timestamp
		
		assert_equal @dev_uuid_v1_u .uuid.timestamp, @dev_uuid_v1_u .uuid_timestamp
		assert_equal @dev_uuid_v1_r .uuid.timestamp, @dev_uuid_v1_r .uuid_timestamp
		assert_equal @dev_uuid_v3   .uuid.timestamp, @dev_uuid_v3   .uuid_timestamp
		assert_equal @dev_uuid_v4   .uuid.timestamp, @dev_uuid_v4   .uuid_timestamp
		assert_equal @dev_uuid_v5   .uuid.timestamp, @dev_uuid_v5   .uuid_timestamp
		assert_equal @dev_uuid_null .uuid.timestamp, @dev_uuid_null .uuid_timestamp
	end
	
	it "should be able to return the MAC address" do
		assert_equal "00:11:22:33:44:55", @dev_uuid_v1_u .uuid_mac_addr
		assert_equal nil                , @dev_uuid_v1_r .uuid_mac_addr
		assert_equal nil                , @dev_uuid_v3   .uuid_mac_addr
		assert_equal nil                , @dev_uuid_v4   .uuid_mac_addr
		assert_equal nil                , @dev_uuid_v5   .uuid_mac_addr
		assert_equal nil                , @dev_uuid_null .uuid_mac_addr
		
		assert_equal @dev_uuid_v1_u .uuid.mac_address, @dev_uuid_v1_u .uuid_mac_addr
		assert_equal @dev_uuid_v1_r .uuid.mac_address, @dev_uuid_v1_r .uuid_mac_addr
		assert_equal @dev_uuid_v3   .uuid.mac_address, @dev_uuid_v3   .uuid_mac_addr
		assert_equal @dev_uuid_v4   .uuid.mac_address, @dev_uuid_v4   .uuid_mac_addr
		assert_equal @dev_uuid_v5   .uuid.mac_address, @dev_uuid_v5   .uuid_mac_addr
		assert_equal @dev_uuid_null .uuid.mac_address, @dev_uuid_null .uuid_mac_addr
	end
	
end

