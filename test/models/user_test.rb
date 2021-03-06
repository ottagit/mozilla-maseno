require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Test Name", email: "test@email.com", password: "passpass", 
                    password_confirmation: "passpass")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "n" * 51
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "e" * 244 + "@invalid.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid emails" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                        first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid emails" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                        foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (non-blank)" do
    @user.password = @user.password_confirmation = "" * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "should destroy associated microposts" do
    @user.save
    @user.microposts.create!(content: "About to be destroyed")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    ben = users(:ben)
    chris = users(:chris)
    assert_not ben.following?(chris)
    ben.follow(chris)
    assert ben.following?(chris)
    assert chris.followers.include?(ben)
    ben.unfollow(chris)
    assert_not ben.following?(chris)
  end

  test "feed should have the right posts" do
    chris = users(:chris)
    sally = users(:sally)
    kyle = users(:kyle)
    # Posts from followed user
    kyle.microposts.each do |post_following|
      assert chris.feed.include?(post_following)
    end
    # Posts from self
    chris.microposts.each do |post_self|
      assert chris.feed.include?(post_self)
    end
    # Posts from unfollowed user
    sally.microposts.each do |post_unfollowed|
      assert_not chris.feed.include?(post_unfollowed)
    end
  end
end
