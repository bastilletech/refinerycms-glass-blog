# encoding: utf-8
require "spec_helper"

describe Refinery do
  describe "Blog" do
    describe "Admin" do
      describe "authors", type: :feature do

        refinery_login_with :refinery_user


        describe "authors list" do
          before do
            FactoryGirl.create(:author, :last_name => "UniqueTitleOne")
            FactoryGirl.create(:author, :last_name => "UniqueTitleTwo")
          end

          it "shows two items" do
            visit refinery.blog_admin_authors_path
            expect(page).to have_content("UniqueTitleOne")
            expect(page).to have_content("UniqueTitleTwo")
          end
        end

        describe "create" do
          before do
            visit refinery.blog_admin_authors_path

            click_link "Add New Author"
          end

          context "valid data" do
            it "should succeed" do
              fill_in "Last Name", :with => "This is a test of the first string field"
              expect { click_button "Save" }.to change(Refinery::Blog::Author, :count).from(0).to(1)

              expect(page).to have_content("'This is a test of the first string field' was successfully added.")
            end
          end

          context "invalid data" do
            it "should fail" do
              expect { click_button "Save" }.not_to change(Refinery::Blog::Author, :count)

              expect(page).to have_content("Last Name can't be blank")
            end
          end

          context "duplicate" do
            before { FactoryGirl.create(:author, :last_name => "UniqueTitle") }

            it "should fail" do
              visit refinery.blog_admin_authors_path

              click_link "Add New Author"

              fill_in "Last Name", :with => "UniqueTitle"
              expect { click_button "Save" }.not_to change(Refinery::Blog::Author, :count)

              expect(page).to have_content("There were problems")
            end
          end

        end

        describe "edit" do
          before { FactoryGirl.create(:author, :last_name => "A last_name") }

          it "should succeed" do
            visit refinery.blog_admin_authors_path

            within ".actions" do
              click_link "Edit this author"
            end

            fill_in "Last Name", :with => "A different last_name"
            click_button "Save"

            expect(page).to have_content("'A different last_name' was successfully updated.")
            expect(page).not_to have_content("A last_name")
          end
        end

        describe "destroy" do
          before { FactoryGirl.create(:author, :last_name => "UniqueTitleOne") }

          it "should succeed" do
            visit refinery.blog_admin_authors_path

            click_link "Remove this author forever"

            expect(page).to have_content("'UniqueTitleOne' was successfully removed.")
            expect(Refinery::Blog::Author.count).to eq(0)
          end
        end

      end
    end
  end
end
