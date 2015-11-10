# encoding: utf-8
require "spec_helper"

describe Refinery do
  describe "Blog" do
    describe "Admin" do
      describe "items", type: :feature do

        refinery_login_with :refinery_user


        describe "items list" do
          before do
            FactoryGirl.create(:item, :title => "UniqueTitleOne")
            FactoryGirl.create(:item, :title => "UniqueTitleTwo")
          end

          it "shows two items" do
            visit refinery.blog_admin_items_path
            expect(page).to have_content("UniqueTitleOne")
            expect(page).to have_content("UniqueTitleTwo")
          end
        end

        describe "create" do
          before do
            visit refinery.blog_admin_items_path

            click_link "Add New Item"
          end

          context "valid data" do
            it "should succeed" do
              fill_in "Title", :with => "This is a test of the first string field"
              expect { click_button "Save" }.to change(Refinery::Blog::Item, :count).from(0).to(1)

              expect(page).to have_content("'This is a test of the first string field' was successfully added.")
            end
          end

          context "invalid data" do
            it "should fail" do
              expect { click_button "Save" }.not_to change(Refinery::Blog::Item, :count)

              expect(page).to have_content("Title can't be blank")
            end
          end

          context "duplicate" do
            before { FactoryGirl.create(:item, :title => "UniqueTitle") }

            it "should fail" do
              visit refinery.blog_admin_items_path

              click_link "Add New Item"

              fill_in "Title", :with => "UniqueTitle"
              expect { click_button "Save" }.not_to change(Refinery::Blog::Item, :count)

              expect(page).to have_content("There were problems")
            end
          end

        end

        describe "edit" do
          before { FactoryGirl.create(:item, :title => "A title") }

          it "should succeed" do
            visit refinery.blog_admin_items_path

            within ".actions" do
              click_link "Edit this item"
            end

            fill_in "Title", :with => "A different title"
            click_button "Save"

            expect(page).to have_content("'A different title' was successfully updated.")
            expect(page).not_to have_content("A title")
          end
        end

        describe "destroy" do
          before { FactoryGirl.create(:item, :title => "UniqueTitleOne") }

          it "should succeed" do
            visit refinery.blog_admin_items_path

            click_link "Remove this item forever"

            expect(page).to have_content("'UniqueTitleOne' was successfully removed.")
            expect(Refinery::Blog::Item.count).to eq(0)
          end
        end

      end
    end
  end
end
