require 'spec_helper'

describe "Authentication" do
	subject { page }
#...............Test for the existence of Sign In page................
	before { visit signin_path }

	it { should have_selector('h1', text: 'Sign In') }
	it { should have_selector('title', text: full_title('Sign In')) }
	it { should have_link('Forgotten Password?', 
				href: new_password_reset_path) }

    describe "signin" do
		
#..................Check for error on invalid data.................
		describe "with invalid information" do
			before { click_button 'Sign In' }

			it { should have_selector('title', text: full_title('Sign In')) }
			it { should have_selector('div.alert.alert-error', text: 'Invalid') }

			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in(user) }

			it { should have_selector('title', text: user.name) }
			it { should have_link('Users', href: users_path) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Settings', href: edit_user_path(user)) }
			it { should have_link('Sign Out', href: signout_path) }
			it { should_not have_link('Sign In', href: signin_path) }

			# describe "inactive user sign in" do
			# 	before do
			# 		click_link "Sign Out"
			# 		user.state = "inactive"
			# 		user.save!
			# 		sign_in(user)
			# 	end 

			# 	it { should have_selector('title', text: 'Sign In') }
			# 	it { should have_selector('div.alert.alert-error', 
			# 		text: "Your account is not activated. Please check your email") }
			# end

			describe "followed by Sign Out" do
				before { click_link "Sign Out" }

				it { should have_link("Sign In") }
				#Test for absence of profile and users link
			end
		end

		describe "inactive user sign in" do
			let(:user) { FactoryGirl.create(:user) }
			before do
				user.state = "inactive"
				user.save!
				sign_in(user)
			end

			it { should have_selector('title', text: 'Sign In') }
			it { should have_selector('div.alert.alert-error', 
					text: "Your account is not activated. Please check your email") }
		end
	end

	describe "authorization" do

		describe "for non-signed in users" do
			let(:user) { FactoryGirl.create(:user) }

			describe "in Users controller" do

				describe "visiting the edit page" do
					before { visit edit_user_path(user) }

					it { should have_selector('title', 
						text: full_title('Sign In')) }
				end

				describe "submitting the update action" do
					before { put user_path(user) }

					specify { response.should redirect_to signin_path }
				end

				describe "visiting the user index" do
					before { visit users_path }

					it { should have_selector('title', 
						text: full_title('Sign In')) }
				end

				describe "visiting the followers page" do
					before { visit followers_user_path(user) }

					it { should have_selector('title', text: 'Sign In') }
				end

				describe "visiting the following page" do
					before { visit following_user_path(user) }

					it { should have_selector('title', text: 'Sign In') }
				end

				describe "visiting the mentions page" do
					before { visit mentions_user_path(user) }

					it { should have_selector('title', text: 'Sign In') }
				end

				describe "visitng the favorites page" do
					before { visit favorites_user_path(user) }

					it { should have_selector('title', text: 'Sign In')}
				end
			end


			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					fill_in "Email", with: user.email
					fill_in "Password", with:user.password
					click_button "Sign In"
				end

				describe "after signing in" do

					it "should render the desired protected page" do
						page.should have_selector('title', 
							text: full_title('Edit user'))
					end
				end
			end

			#...........For Microposts.........
			describe "in the micoposts controller" do
				describe "when trying to create micropost" do
					before { post microposts_path }

					specify { response.should redirect_to(signin_path) }
				end

				describe "when trying to destroy micropost" do
					before { delete micropost_path(FactoryGirl.create(:micropost)) }

					specify { response.should redirect_to(signin_path) }
				end
			end

			describe "in the Relationships Controller" do
				describe "submitting to the create action" do
					before { post relationships_path }
					
					specify { response.should redirect_to(signin_path) }
				end

				describe "attempting to delete a relationship" do
					before { delete relationship_path(1) }

					specify { response.should redirect_to(signin_path) }
				end
			end

			describe "in the Favorites Controller" do
				describe "submitting to the create action" do
					before { post favorites_path }

					specify { response.should redirect_to(signin_path) }
				end

				describe "submitting to the destroy action" do
					before { delete favorite_path(1) }

					specify { response.should redirect_to(signin_path) }
				end
			end
		end

		describe "as wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user, 
				email: "jk@example.com", username: "ik") }
			before { sign_in user }

			describe "visiting users#edit page" do
				before { visit edit_user_path(wrong_user) }
				it { should_not have_selector('title', 
					text: full_title('Edit user')) }
			end

			describe "visiting users#mentions page" do
				before { visit mentions_user_path(wrong_user) }

				it { should_not have_selector('title',
						text: 'Mentions') }
			end

			describe "submitting the PUT request to update action for user" do
				before { put user_path(wrong_user) }
				it { response.should redirect_to(root_path) }
			end
		end



		describe "as non-admin users" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }

			before { sign_in non_admin }

			describe "Deleting users through destroy action" do
				before { delete user_path(user) }

				specify { response.should redirect_to(root_path) }
			end
		end
	end


end