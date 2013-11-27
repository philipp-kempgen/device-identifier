require 'bundler/setup'
require 'minitest/spec'
require 'minitest/autorun'
require 'dev-id'

MacAddress = DevId::MacAddress
MacAddressOui = DevId::MacAddressOui
MacAddressPartial = DevId::MacAddressPartial

describe DevId::MacAddress do
	
	before do
		@m = MacAddress.from_hex "00:11:22:AA:BB:CC"
	end
	
	[
		"",
		nil,
		"00:11:22:33:44",
		"00:11:22:33:44:55:66",
		":",
		
	].each{ |v|
		it "should not be valid for #{v.inspect}" do
			m = MacAddress.from_hex v
			assert_equal false, m.valid?
		end
	}
	
	[
		"00:11:22:33:44:55",
		"11:22:33:44:55:66",
		"001122aabbcc",
		
	].each{ |v|
		it "should be valid for #{v.inspect}" do
			m = MacAddress.from_hex v
			assert_equal true, m.valid?
		end
	}
	
	it "should be valid" do
		assert_equal true, @m.valid?
	end
	
	it "should be equal" do
		a = MacAddress.from_hex "001122aabbcc"
		b = MacAddress.from_hex "00-11-22-AA-BB-CC"
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
		a = MacAddress.from_hex "00:11:22:33:44:55"
		b = MacAddress.from_hex "00:11:22:33:44:66"
		assert a != b
		assert b != a
		assert ! a.eql?( b )
		assert ! b.eql?( a )
	end
	
	it "should be comparable" do
		a = MacAddress.from_hex "001122aabbcc"
		b = MacAddress.from_hex "00-11-22-AA-BB-CC"
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
	
	it "should support an ASCII representation" do
		assert_equal "001122aabbcc", @m.ascii
	end
	
	it "should support a pretty representation" do
		assert_equal "00:11:22:AA:BB:CC", @m.pretty
	end
	
	it "should support .to_s" do
		assert_equal "00:11:22:AA:BB:CC", @m.to_s
	end
	
	it "should support pretty() with options" do
		assert_equal "00-11-22-aa-bb-cc", @m.pretty({ :sep => '-', :upcase => false })
	end
	
	it "should support a raw representation" do
		assert_equal "\x00\x11\x22\xAA\xBB\xCC", @m.raw
	end
	
	it "should support a bytesize" do
		assert_equal 6, @m.bytesize
	end
	
	it "should support a bytes enumerator" do
		assert_kind_of ::Enumerator, @m.bytes
	end
	
	it "should support a bytes representation" do
		assert_equal [ 0x00, 0x11, 0x22, 0xAA, 0xBB, 0xCC ], @m.bytes.to_a
	end
	
	it "should support .getbyte()" do
		{
			 0 => 0x00,
			 1 => 0x11,
			 2 => 0x22,
			 3 => 0xAA,
			 4 => 0xBB,
			 5 => 0xCC,
			 6 => nil,
			-1 => 0xCC,
			-2 => 0xBB,
			
		}.each{ |idx, expected|
			assert_equal expected, @m.getbyte( idx ), "#{self.class.name}.from_hex( #{@m.pretty.inspect} ).getbyte( #{idx.inspect} ) should return #{expected.inspect}"
		}
	end
	
	it "should support .byteslice()" do
		{
			[  0 ] => "\x00",
			[  1 ] => "\x11",
			[  2 ] => "\x22",
			[  3 ] => "\xAA",
			[  4 ] => "\xBB",
			[  5 ] => "\xCC",
			[  6 ] => nil,
			[ -1 ] => "\xCC",
			[ -2 ] => "\xBB",
			
			[  2,  2 ] => "\x22\xAA",
			[  2, -2 ] => nil,
			[ -3, -2 ] => nil,
			[ -3,  2 ] => "\xAA\xBB",
			[ -3,  9 ] => "\xAA\xBB\xCC",
			
		}.each{ |args, expected|
			assert_equal expected, @m.byteslice( *args ), "#{self.class.name}.from_hex( #{@m.pretty.inspect} ).byteslice( *#{args.inspect} ) should return #{expected.inspect}"
		}
	end
	
	it "should start with OUI" do
		oui1 = MacAddressOui.from_hex '00:11:22'
		oui2 = MacAddressOui.from_hex '00:11:33'
		assert oui1.valid?, "OUI #{oui1.inspect} should be valid"
		assert oui2.valid?, "OUI #{oui2.inspect} should be valid"
		assert @m.starts_with?( oui1 ), "#{@m.inspect} should start with #{oui1.inspect}"
		assert @m.start_with?(  oui1 ), "#{@m.inspect} should start with #{oui1.inspect}"
		assert ! @m.starts_with?( oui2 ), "#{@m.inspect} should not start with #{oui2.inspect}"
		assert ! @m.start_with?(  oui2 ), "#{@m.inspect} should not start with #{oui2.inspect}"
	end
	
	it "should start with partial MAC address" do
		part1 = MacAddressPartial.from_hex '00:11:22:aa'
		part2 = MacAddressPartial.from_hex '00:11:22:00'
		assert part1.valid?, "partial #{part1.inspect} should be valid"
		assert part2.valid?, "partial #{part2.inspect} should be valid"
		assert @m.starts_with?( part1 ), "#{@m.inspect} should start with #{part1.inspect}"
		assert @m.start_with?(  part1 ), "#{@m.inspect} should start with #{part1.inspect}"
		assert ! @m.starts_with?( part2 ), "#{@m.inspect} should not start with #{part2.inspect}"
		assert ! @m.start_with?(  part2 ), "#{@m.inspect} should not start with #{part2.inspect}"
	end
	
	it "should not be the null address" do
		assert ! @m.null?
	end
	
	it "should be the null address" do
		assert MacAddress.from_hex( "00:00:00:00:00:00" ).null?
	end
	
	it "should not be a multicast address" do
		assert ! @m.multicast?
		
		assert ! MacAddress.from_hex( "00:00:00:00:00:00" ).multicast?
		assert ! MacAddress.from_hex( "02:00:00:00:00:00" ).multicast?
		assert ! MacAddress.from_hex( "04:00:00:00:00:00" ).multicast?
		assert ! MacAddress.from_hex( "06:00:00:00:00:00" ).multicast?
	end
	
	it "should be a multicast address" do
		assert MacAddress.from_hex( "01:00:00:00:00:00" ).multicast?
		assert MacAddress.from_hex( "03:00:00:00:00:00" ).multicast?
		assert MacAddress.from_hex( "05:00:00:00:00:00" ).multicast?
	end
	
	it "should not be a local address" do
		assert ! @m.local?
		
		assert ! MacAddress.from_hex( "00:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "01:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "04:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "05:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "08:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "09:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "0C:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "0D:00:00:00:00:00" ).local?
		
		assert ! MacAddress.from_hex( "10:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "11:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "14:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "15:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "18:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "19:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "1C:00:00:00:00:00" ).local?
		assert ! MacAddress.from_hex( "1D:00:00:00:00:00" ).local?
	end
	
	it "should be a local address" do
		assert MacAddress.from_hex( "02:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "03:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "06:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "07:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "0A:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "0B:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "0E:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "0F:00:00:00:00:00" ).local?
		
		assert MacAddress.from_hex( "12:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "13:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "16:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "17:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "1A:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "1B:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "1E:00:00:00:00:00" ).local?
		assert MacAddress.from_hex( "1F:00:00:00:00:00" ).local?
	end
	
	it "should provide the OUI" do
		assert_equal "\x00\x11\x22", @m.oui_raw
		assert @m.starts_with?( MacAddressPartial.from_raw( @m.oui_raw ))
	end
	
end

