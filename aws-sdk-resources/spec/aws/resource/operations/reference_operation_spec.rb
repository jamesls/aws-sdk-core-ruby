require 'spec_helper'

module Aws
  module Resource
    module Operations
      describe ReferenceOperation do
        describe '#request' do

          it 'returns the builder given to the constructor' do
            builder = double('builder')
            operation = ReferenceOperation.new(builder: builder)
            expect(operation.builder).to be(builder)
          end

          it 'requries a :builder option' do
            msg = 'missing required option :builder'
            expect {
              ReferenceOperation.new
            }.to raise_error(Errors::DefinitionError, msg)
          end

        end

        context '#call' do

          it 'calls the builder, returning the resource' do
            resource_class = Resource.define(double('client-class'), ['id'])
            resource_class.add_operation(:get_linked, ReferenceOperation.new(
              builder: Builder.new(resource_class:resource_class, sources:[
                BuilderSources::DataMember.new('ids[]', 'id')
              ])
            ))
            resource_class.const_set(:Batch, Class.new(Resource::Batch))
            client = double('client')
            resource = resource_class.new(
              id: 'parent',
              client: client,
              data: { 'ids' => %w(child-1 child-2) }
            )
            linked = resource.get_linked
            expect(linked).to be_a(resource_class::Batch)
            expect(linked).to be_kind_of(Resource::Batch)
            expect(linked.size).to eq(2)
            expect(linked[0].id).to eq('child-1')
            expect(linked[1].id).to eq('child-2')
          end

        end
      end
    end
  end
end
