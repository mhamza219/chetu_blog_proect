class HardJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
    Blog.first.update(title: "name_chage_sidekiq")
  end
end
