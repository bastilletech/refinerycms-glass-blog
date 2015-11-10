# encoding: utf-8
require "spec_helper"

describe Refinery do
  describe "Blog" do
    describe "Admin" do
      describe "sections", type: :feature do

        refinery_login_with :refinery_user


        describe "sections list" do
          before do
            FactoryGirl.create(:section, :slug => "UniqueTitleOne")
            FactoryGirl.create(:section, :slug => "UniqueTitleTwo")
          end

          it "shows two items" do
            visit refinery.blog_admin_sections_path
            expect(page).to have_content("UniqueTitleOne")
            expect(page).to have_content("UniqueTitleTwo")
          end
        end

        describe "create" do
          before do
            visit refinery.blog_admin_sections_path

            click_link "Add New Section"
          end

          context "valid data" do
            it "should succeed" do
              fill_in "Slug", :with => "This is a test of the first string field"
              expect { click_button "Save" }.to change(Refinery::Blog::Section, :count).from(0).to(1)

              expect(page).to have_content("'This is a test of the first string field' was successfully added.")
            end
          end

          context "invalid data" do
            it "should fail" do
              expect { click_button "Save" }.not_to change(Refinery::Blog::Section, :count)

              expect(page).to have_content("Slug can't be blank")
            end
          end

          context "duplicate" do
            before { FactoryGirl.create(:section, :slug => "UniqueTitle") }

            it "should fail" do
              visit refinery.blog_admin_sections_path

              click_link "Add New Section"

              fill_in "Slug", :with => "UniqueTitle"
              expect { click_button "Save" }.not_to change(Refinery::Blog::Section, :count)

              expect(page).to have_content("There were problems")
            end
          end

        end

        describe "edit" do
          before { FactoryGirl.create(:section, :slug => "A slug") }

          it "should succeed" do
            visit refinery.blog_admin_sections_path

            within ".actions" do
              click_link "Edit this section"
            end

            fill_in "Slug", :with => "A different slug"
            click_button "Save"

            expect(page).to have_content("'A different slug' was successfully updated.")
            expect(page).not_to have_content("A slug")
          end
        end

        describe "destroy" do
          before { FactoryGirl.create(:section, :slug => "UniqueTitleOne") }

          it "should succeed" do
            visit refinery.blog_admin_sections_path

            click_link "Remove this section forever"

            expect(page).to have_content("'UniqueTitleOne' was successfully removed.")
            expect(Refinery::Blog::Section.count).to eq(0)
          end
        end

      end
    end
  end
end
