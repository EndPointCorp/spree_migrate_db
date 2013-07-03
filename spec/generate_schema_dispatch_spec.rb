require 'spec_helper'


class TestDefinition
  def to_s; "test_definition"; end
  def spree_version
    "0.50.0"
  end
  def to_hash
    { version: "0.50.0", tables: {} }
  end
end

class InvalidSchemaDefinition; end

module SpreeMigrateDB
  describe GenerateSchemaDispatch do
    before { GenerateSchemaDispatch.clear_subscriptions }
    let(:d) { TestDefinition.new }

    context "when subscribing to the dispatch" do

      it "subscribes a schema definition" do
        subscription = GenerateSchemaDispatch.subscribe d

        subscription.should be_instance_of TestDefinition
        subscription.spree_version.should == '0.50.0'
      end

      it "rejects the subscription if it doesn't have the proper interface" do
        expect {
          GenerateSchemaDispatch.subscribe InvalidSchemaDefinition.new
        }.to raise_error InvalidSchemaDefinitionError
      end

      it "rejects the subscription if there is already a generator registered for that version" do
        original = GenerateSchemaDispatch.subscribe d
        new =  GenerateSchemaDispatch.subscribe d
        new.should == original
      end

    end

    context "when getting the schema" do
      it "dispatches the call to the appropriate subscribed definition" do
        GenerateSchemaDispatch.subscribe d
        schema = GenerateSchemaDispatch.get_definition({:spree_version => "0.50.0"})
        schema.to_hash.should == TestDefinition.new.to_hash
      end

      it "generates an error if there are no subscribed definitions for the version" do
        expect{
          GenerateSchemaDispatch.get_definition({:spree_version => "0.60.0"})
        }.to raise_error GenerateSchemaDispatch::NoVersionFoundError

      end

      it "generates an error if the header is invalid" do
        expect {
          GenerateSchemaDispatch.get_definition({})
        }.to raise_error GenerateSchemaDispatch::NoVersionFoundError
      end

    end

  end
end
