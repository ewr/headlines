class CreateHeadlinesHeadlines < ActiveRecord::Migration
  def change
    create_table :headlines_headlines do |t|
      t.string :title, :url, :null => false
      t.text :intro
      t.text :excerpt
      t.integer :asset_id
      t.belongs_to :user
      t.timestamps
    end
  end
end
