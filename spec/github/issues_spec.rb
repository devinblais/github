# encoding: utf-8

require 'spec_helper'

describe Github::Issues do
  let(:issues_api) { Github::Issues }
  let(:github) { Github.new }
  let(:user)   { 'peter-murach' }
  let(:repo)   { 'github' }
  let(:issue_id) { 1347 }

  after { reset_authentication_for github }

  its(:comments) { should be_a Github::Issues::Comments }
  its(:events)   { should be_a Github::Issues::Events }
  its(:labels)   { should be_a Github::Issues::Labels }
  its(:milestones) { should be_a Github::Issues::Milestones }

  describe "#create" do
    let(:inputs) {
      {
         "title" =>  "Found a bug",
         "body" => "I'm having a problem with this.",
         "assignee" =>  "octocat",
         "milestone" => 1,
         "labels" => [
           "Label1",
           "Label2"
         ]
      }
    }
    context "resouce created" do
      before do
        stub_post("/repos/#{user}/#{repo}/issues").with(inputs).
          to_return(:body => fixture('issues/issue.json'), :status => 201, :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should fail to create resource if 'title' input is missing" do
        expect {
          github.issues.create user, repo, inputs.except('title')
        }.to raise_error(Github::Error::RequiredParams)
      end

      it "should create resource successfully" do
        github.issues.create user, repo, inputs
        a_post("/repos/#{user}/#{repo}/issues").with(inputs).should have_been_made
      end

      it "should return the resource" do
        issue = github.issues.create user, repo, inputs
        issue.should be_a Hashie::Mash
      end

      it "should get the issue information" do
        issue = github.issues.create(user, repo, inputs)
        issue.title.should == 'Found a bug'
      end
    end

    context "failed to create resource" do
      before do
        stub_post("/repos/#{user}/#{repo}/issues").with(inputs).
          to_return(:body => fixture('issues/issue.json'), :status => 404, :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should faile to retrieve resource" do
        expect {
          github.issues.create user, repo, inputs
        }.to raise_error(Github::Error::NotFound)
      end
    end
  end # create

  describe "#edit" do
    let(:inputs) {
      {
         "title" =>  "Found a bug",
         "body" => "I'm having a problem with this.",
         "assignee" =>  "octocat",
         "milestone" => 1,
         "labels" => [
           "Label1",
           "Label2"
         ]
      }
    }

    context "resource edited successfully" do
      before do
        stub_patch("/repos/#{user}/#{repo}/issues/#{issue_id}").with(inputs).
          to_return(:body => fixture("issues/issue.json"), :status => 200, :headers => { :content_type => "application/json; charset=utf-8"})
      end

      it "should fail to edit without 'user/repo' parameters" do
        expect {
          github.issues.edit nil, repo, issue_id
        }.to raise_error(ArgumentError)
      end

      it "should edit the resource" do
        github.issues.edit user, repo, issue_id, inputs
        a_patch("/repos/#{user}/#{repo}/issues/#{issue_id}").with(inputs).should have_been_made
      end

      it "should return resource" do
        issue = github.issues.edit user, repo, issue_id, inputs
        issue.should be_a Hashie::Mash
      end

      it "should be able to retrieve information" do
        issue = github.issues.edit user, repo, issue_id, inputs
        issue.title.should == 'Found a bug'
      end
    end

    context "failed to edit resource" do
      before do
        stub_patch("/repos/#{user}/#{repo}/issues/#{issue_id}").with(inputs).
          to_return(:body => fixture("issues/issue.json"), :status => 404, :headers => { :content_type => "application/json; charset=utf-8"})
      end

      it "should fail to find resource" do
        expect {
          github.issues.edit user, repo, issue_id, inputs
        }.to raise_error(Github::Error::NotFound)
      end
    end
  end # edit

end # Github::Issues
