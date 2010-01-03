require 'helper'

describe BloomFilter do

  context "behave like a bloomfilter" do
    it "should test set memerbship" do
      bf = BloomFilter.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
      bf.insert("test")
      bf.insert("test1")

      bf.include?("test").should be_true
      bf.include?("abcd").should be_false
      bf.include?("test", "test1").should be_true
    end

    it "should work with symbol keys" do
      bf = BloomFilter.new
      bf.insert(:test)
      bf.insert(:test1)
    
      bf.include?("test").should be_true
      bf.include?("abcd").should be_false
      bf.include?("test", "test1").should be_true
    end
  end
  
  context "behave like counting bloom filter" do
    it "should delete / decrement keys" do
      bf = BloomFilter.new

      bf.insert("test")
      bf.include?("test").should be_true

      bf.delete("test")
      bf.include?("test").should be_false
    end
  end
  
  context "behave like a Hash" do
    it "should respond to key?" do
      bf = BloomFilter.new
 
      bf['foo'] = 'bar'
      bf.key?('foo').should be_true
    end
    
    it "should optionally store the hash values" do
      bf = BloomFilter.new(:values => true)
      bf['foo'] = 'bar'

      bf.key?('foo').should be_true
      bf['foo'].should == 'bar'
    end
    
    it "should provide a list of keys" do
      bf = BloomFilter.new(:values => true)
      bf['foo'] = 'bar'
      bf['awesome'] = 'bar'
      %w{ awesome foo }.sort.should == bf.keys.sort

      # don't store values by default
      bf = BloomFilter.new
      bf['foo'] = 'bar'
      bf.keys.should be_nil
    end
  end

end
