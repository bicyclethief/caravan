require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:testuser) { FactoryGirl.create :user }
  let(:user_params) { FactoryGirl.attributes_for(:user) }
  before :each do
    session[:user_id] = testuser.id
  end

  describe "#new" do
    it "renders the :new view" do
      get :new
      expect(response).to render_template :new
    end
  end

  context "#create" do
    it "redirects to the users profile" do
      expect{post :create, user: FactoryGirl.attributes_for(:user)}.to change(User, :count).by(1)
    end

    it "does not redirect with bad attributes" do
      post :create, user: {username: nil , password: "wdw"}
      expect(response).to redirect_to new_user_path
    end
  end

  describe "#show" do
    it "renders the show template" do
      get :show, id: testuser.id
      expect(response).to render_template :show
    end
  end

  describe "#current" do
    it "renders the current view template" do
      get :current, user: testuser
      expect(response).to render_template :current
    end
  end
end
