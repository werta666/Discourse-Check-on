# frozen_string_literal: true

require 'rails_helper'

describe DiscourseCheckOnController do
  before do
    SiteSetting.discourse_check_on_enabled = true
  end

  describe '#index' do
    it 'returns plugin information when enabled' do
      get '/discourse-check-on'
      
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      
      expect(json['enabled']).to eq(true)
      expect(json['message']).to be_present
      expect(json['feature_level']).to be_present
    end

    it 'works when plugin is disabled' do
      SiteSetting.discourse_check_on_enabled = false
      
      get '/discourse-check-on'
      
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      
      expect(json['enabled']).to eq(false)
    end
  end

  describe '#toggle' do
    context 'when user is admin' do
      let(:admin) { Fabricate(:admin) }

      before do
        sign_in(admin)
      end

      it 'can enable the plugin' do
        SiteSetting.discourse_check_on_enabled = false
        
        post '/discourse-check-on/toggle', params: { status: 'true' }
        
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        
        expect(json['success']).to eq(true)
        expect(json['enabled']).to eq(true)
        expect(SiteSetting.discourse_check_on_enabled).to eq(true)
      end

      it 'can disable the plugin' do
        SiteSetting.discourse_check_on_enabled = true
        
        post '/discourse-check-on/toggle', params: { status: 'false' }
        
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        
        expect(json['success']).to eq(true)
        expect(json['enabled']).to eq(false)
        expect(SiteSetting.discourse_check_on_enabled).to eq(false)
      end
    end

    context 'when user is not admin' do
      let(:user) { Fabricate(:user) }

      before do
        sign_in(user)
      end

      it 'returns 403 forbidden' do
        post '/discourse-check-on/toggle', params: { status: 'true' }
        
        expect(response.status).to eq(403)
        json = JSON.parse(response.body)
        
        expect(json['error']).to be_present
      end
    end

    context 'when user is not logged in' do
      it 'returns 403 forbidden' do
        post '/discourse-check-on/toggle', params: { status: 'true' }
        
        expect(response.status).to eq(403)
      end
    end
  end

  describe '#stats' do
    let!(:users) { Fabricate.times(5, :user) }
    let!(:topics) { Fabricate.times(3, :topic) }

    it 'returns statistics' do
      get '/discourse-check-on/stats'
      
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      
      expect(json['total_users']).to be >= 5
      expect(json['total_topics']).to be >= 3
      expect(json['active_users']).to be >= 0
      expect(json['check_on_topics']).to be >= 0
    end
  end
end
