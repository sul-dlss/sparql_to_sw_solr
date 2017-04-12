RSpec.describe SparqlToSwSolr::InstanceSolrDoc::PhysicalField do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }
  let(:sparql_conn) { double('sparql client') }
  let(:solutions) { RDF::Query::Solutions.new }

  before(:each) do
    allow(isd).to receive(:sparql).and_return(sparql_conn)
    allow(sparql_conn).to receive(:query).and_return(solutions)
  end

  context '#physical_values' do
    it 'is a String consisting of the results from a query solution' do
      solutions << RDF::Query::Solution.new(noteType: 'Physical details',
                                            extentLabel_1: '15 p.',
                                            noteLabel: 'ill.',
                                            instanceDimensions_3: '5 x 5 in.')
      physical_values = isd.send(:physical_values)
      expect(physical_values).to eq '15 p. : ill. ; 5 x 5 in.'
    end
    it 'includes noteLabel for "accompanying material" when it exists as a solutions with a different noteType' do
      solutions << RDF::Query::Solution.new(noteType: 'Physical details',
                                            extentLabel_1: '15 p.',
                                            noteLabel: 'ill.',
                                            instanceDimensions_3: '5 x 5 in.')
      solutions << RDF::Query::Solution.new(noteType: 'Accompanying materials',
                                            extentLabel_1: '15 p.',
                                            noteLabel: 'CD',
                                            instanceDimensions_3: '5 x 5 in.')
      physical_values = isd.send(:physical_values)
      expect(physical_values).to eq '15 p. : ill. ; 5 x 5 in. + CD'
    end
    it 'Concatenates the physical_details correctly if there is no extentLabel_1' do
      solutions << RDF::Query::Solution.new(noteType: 'Physical details',
                                            extentLabel_1: nil,
                                            noteLabel: 'ill.',
                                            instanceDimensions_3: '5 x 5 in.')
      physical_values = isd.send(:physical_values)
      expect(physical_values).to eq 'ill. ; 5 x 5 in.'
    end
    it 'Concatenates the physical_details correctly if there is no instanceDimensions_3' do
      solutions << RDF::Query::Solution.new(noteType: 'Physical details',
                                            extentLabel_1: '15 p.',
                                            noteLabel: 'ill.',
                                            instanceDimensions_3: nil)
      physical_values = isd.send(:physical_values)
      expect(physical_values).to eq '15 p. : ill.'
    end
    it 'Leaves out the noteLabel if neither noteType "Accompanying material" or "Physical details" exist' do
      solutions << RDF::Query::Solution.new(noteType: 'foo',
                                            extentLabel_1: '15 p.',
                                            noteLabel: 'ill.',
                                            instanceDimensions_3: '5 x 5 in.')
      physical_values = isd.send(:physical_values)
      expect(physical_values).to eq '15 p. ; 5 x 5 in.'
    end
    it 'Returns nothing if there is no noteType' do
      solutions << RDF::Query::Solution.new(extentLabel_1: '15 p.',
                                            noteLabel: 'ill.',
                                            instanceDimensions_3: '5 x 5 in.')
      physical_values = isd.send(:physical_values)
      expect(physical_values).to eq nil
    end
  end
end
