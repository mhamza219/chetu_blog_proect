class BlogMailer < ApplicationMailer
  default from: "no-reply@example.com"

  def blog_created(blog)
    # byebug
    @blog = blog
    @user = blog.user
    mail(to: @user.email, subject: "Your blog has been created")
  end

  def blog_deleted(blog)
    @blog = blog
    @user = blog.user
    mail(to: @user.email, subject: "Your blog has been deleted")
  end

  # without views file:

  # def blog_created(blog)
  #   @blog = blog
  #   @user = blog.user

  #   mail(
  #     to: @user.email,
  #     subject: "Your blog has been created",
  #     body: <<~BODY
  #       Hello #{@user.email},

  #       Your blog "#{@blog.title}" has been created successfully.

  #       Thanks,
  #       Team
  #     BODY
  #   )
  # end
#####################################
  # With inline format:
  # def blog_created(blog)
  #   @blog = blog
  #   @user = blog.user

  #   mail(to: @user.email, subject: "Blog Created") do |format|
  #     format.text do
  #       render plain: <<~TEXT
  #         Hello #{@user.email},

  #         Your blog "#{@blog.title}" has been created successfully.
  #       TEXT
  #     end
  #   end
  # end

end
