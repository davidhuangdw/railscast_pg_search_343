class Article < ActiveRecord::Base
  belongs_to :author
  has_many :comments


  include PgSearch
  pg_search_scope :search, against:[:name, :content],
                  using: {tsearch:{dictionary:'english'}},
                  associated_against: {author: :name, comments: [:name, :content]}
                  # ignoring: :accents

  scope :text_search, ->(query)do
    if query.present?
      # rank = <<-RANK
      #   ts_rank(to_tsvector(name), to_tsquery(#{sanitize(query)})) +
      #   ts_rank(to_tsvector(content), to_tsquery(#{sanitize(query)}))
      # RANK
      # where("name @@ :q or content @@ :q", q: query)
      rank = <<-RANK
        ts_rank(to_tsvector(name), plainto_tsquery(#{sanitize(query)}))
      RANK
      query = query
      where("name @@ :q or content @@ :q", q: query).order("#{rank} desc")
    end
  end
end
