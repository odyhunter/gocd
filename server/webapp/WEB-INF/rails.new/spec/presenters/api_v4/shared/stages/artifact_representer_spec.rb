##########################################################################
# Copyright 2017 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require 'rails_helper'

describe ApiV4::Shared::Stages::ArtifactRepresenter do
  it 'should serialize build artifact' do
    presenter   = ApiV4::Shared::Stages::ArtifactRepresenter.new(ArtifactConfig.new('target/dist.jar', 'pkg'))
    actual_json = presenter.to_hash(url_builder: UrlBuilder.new)

    expect(actual_json).to eq(build_artifact_hash)
  end

  it 'should serialize test artifact' do
    config = TestArtifactConfig.new
    config.setSource('target/reports/**/*Test.xml')
    config.setDestination('reports')
    presenter   = ApiV4::Shared::Stages::ArtifactRepresenter.new(config)
    actual_json = presenter.to_hash(url_builder: UrlBuilder.new)

    expect(actual_json).to eq(test_artifact_hash)
  end

  it 'should deserialize test artifact' do
    expected = TestArtifactConfig.new
    expected.setSource('target/reports/**/*Test.xml')
    expected.setDestination('reports')

    actual    = TestArtifactConfig.new
    presenter = ApiV4::Shared::Stages::ArtifactRepresenter.new(actual)
    presenter.from_hash(test_artifact_hash)
    expect(actual.getSource).to eq(expected.getSource)
    expect(actual.getDestination).to eq(expected.getDestination)
    expect(actual.getArtifactType).to eq(expected.getArtifactType)
    expect(actual).to eq(expected)
  end

  it 'should map errors' do
    plan = TestArtifactConfig.new(nil, '../foo')

    plan.validateTree(PipelineConfigSaveValidationContext.forChain(true, "g", PipelineConfig.new, StageConfig.new, JobConfig.new))
    presenter   = ApiV4::Shared::Stages::ArtifactRepresenter.new(plan)
    actual_json = presenter.to_hash(url_builder: UrlBuilder.new)

    expect(actual_json).to eq(test_artifact_with_errors)
  end

  def test_artifact_with_errors
    {source: nil, destination: '../foo', type: 'test',
     errors: {
       destination: ['Invalid destination path. Destination path should match the pattern (([.]\\/)?[.][^. ]+)|([^. ].+[^. ])|([^. ][^. ])|([^. ])'],
       source:      ["Job 'null' has an artifact with an empty source"]
     }
    }
  end

  def build_artifact_hash
    {
      source:      'target/dist.jar',
      destination: 'pkg',
      type:        'build'
    }
  end

  def build_artifact_hash_with_errors
    {
      source:      nil,
      destination: '../foo',
      type:        'build',
      errors:      {
        source:      ["Job 'null' has an artifact with an empty source"],
        destination: ['Invalid destination path. Destination path should match the pattern '+ com.thoughtworks.go.config.validation.FilePathTypeValidator::PATH_PATTERN]
      }
    }
  end

  def test_artifact_hash
    {
      source:      'target/reports/**/*Test.xml',
      destination: 'reports',
      type:        'test'
    }
  end


  def test_artifact_hash_with_errors
    {
      source:      nil,
      destination: '../foo',
      type:        'test',
      errors:      {
        source:      ["Job 'null' has an artifact with an empty source"],
        destination: ['Invalid destination path. Destination path should match the pattern '+ com.thoughtworks.go.config.validation.FilePathTypeValidator::PATH_PATTERN]
      }
    }
  end
end
