class AddInstanceUrlToAuthentication < ActiveRecord::Migration
  def change
    add_column :authentications, :instance_url, :string
  end
end
