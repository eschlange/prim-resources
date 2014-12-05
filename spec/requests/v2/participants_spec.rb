require 'rails_helper'

RSpec.describe 'Participants resource', type: :request do
  include_examples 'requests'

  fixtures :all

  describe 'GET /v2/participants' do
    context 'for a consumer scoped to a single project' do
      it 'sends the participants in that project' do
        get '/v2/participants', nil, single_project_auth_header

        expect(response).to be_success
        expect(json['participants'].length)
          .to be Project.first.participants.count
      end
    end

    context 'for a consumer scoped to all projects' do
      it 'sends all participants' do
        get '/v2/participants', nil, all_project_auth_header

        expect(response).to be_success
        expect(json['participants'].length).to be Participant.count
      end
    end
  end

  describe 'GET /v2/participants/:id' do
    context 'when the participant is found' do
      let(:participant) { Project.first.participants.first }

      it 'sends the participant' do
        get "/v2/participants/#{ participant.external_id }",
            nil,
            all_project_auth_header

        expect(response).to be_success
        expect(json['participants']['id']).to eq participant.external_id
      end
    end

    context 'when the participant is not found anywhere' do
      it 'sends an error' do
        get '/v2/participants/baz', nil, all_project_auth_header

        expect(response).to be_not_found
        expect(json['errors']).not_to be_nil
      end
    end

    context 'when the participant is not found in a project' do
      it 'sends an error' do
        get "/v2/participants/#{ participants(:participant_0).external_id }",
            nil,
            single_project_auth_header

        expect(response).to be_not_found
        expect(json['errors']).not_to be_nil
      end
    end
  end
end