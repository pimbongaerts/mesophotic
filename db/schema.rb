# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170913080739) do

  create_table "comments", force: :cascade do |t|
    t.integer "commentable_id"
    t.string  "commentable_type"
    t.integer "user_id"
    t.string  "content"
    t.boolean "internal"
    t.boolean "request"
    t.boolean "request_handled"
    t.string  "request_response"
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"

  create_table "expeditions", force: :cascade do |t|
    t.string   "title"
    t.integer  "year"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "url"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "description"
    t.string   "featured_image_file_name"
    t.string   "featured_image_content_type"
    t.integer  "featured_image_file_size"
    t.datetime "featured_image_updated_at"
    t.string   "featured_image_credits"
  end

  create_table "expeditions_fields", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "field_id"
  end

  add_index "expeditions_fields", ["expedition_id"], name: "index_expeditions_fields_on_expedition_id"
  add_index "expeditions_fields", ["field_id"], name: "index_expeditions_fields_on_field_id"

  create_table "expeditions_focusgroups", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "focusgroup_id"
  end

  add_index "expeditions_focusgroups", ["expedition_id"], name: "index_expeditions_focusgroups_on_expedition_id"
  add_index "expeditions_focusgroups", ["focusgroup_id"], name: "index_expeditions_focusgroups_on_focusgroup_id"

  create_table "expeditions_locations", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "location_id"
  end

  add_index "expeditions_locations", ["expedition_id"], name: "index_expeditions_locations_on_expedition_id"
  add_index "expeditions_locations", ["location_id"], name: "index_expeditions_locations_on_location_id"

  create_table "expeditions_organisations", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "organisation_id"
  end

  add_index "expeditions_organisations", ["expedition_id"], name: "index_expeditions_organisations_on_expedition_id"
  add_index "expeditions_organisations", ["organisation_id"], name: "index_expeditions_organisations_on_organisation_id"

  create_table "expeditions_platforms", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "platform_id"
  end

  add_index "expeditions_platforms", ["expedition_id"], name: "index_expeditions_platforms_on_expedition_id"
  add_index "expeditions_platforms", ["platform_id"], name: "index_expeditions_platforms_on_platform_id"

  create_table "expeditions_users", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "user_id"
  end

  add_index "expeditions_users", ["expedition_id"], name: "index_expeditions_users_on_expedition_id"
  add_index "expeditions_users", ["user_id"], name: "index_expeditions_users_on_user_id"

  create_table "expertises_users", id: false, force: :cascade do |t|
    t.integer "user_id",      limit: 4
    t.integer "expertise_id", limit: 4
  end

  add_index "expertises_users", ["expertise_id"], name: "index_expertises_users_on_expertise_id"
  add_index "expertises_users", ["user_id"], name: "index_expertises_users_on_user_id"

  create_table "fields", force: :cascade do |t|
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "fields_publications", id: false, force: :cascade do |t|
    t.integer "field_id",       limit: 4
    t.integer "publication_id", limit: 4
  end

  add_index "fields_publications", ["field_id"], name: "index_fields_publications_on_field_id"
  add_index "fields_publications", ["publication_id"], name: "index_fields_publications_on_publication_id"

  create_table "focusgroups", force: :cascade do |t|
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "focusgroups_publications", id: false, force: :cascade do |t|
    t.integer "focusgroup_id",  limit: 4
    t.integer "publication_id", limit: 4
  end

  add_index "focusgroups_publications", ["focusgroup_id"], name: "index_focusgroups_publications_on_focusgroup_id"
  add_index "focusgroups_publications", ["publication_id"], name: "index_focusgroups_publications_on_publication_id"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "journals", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.boolean  "open_access"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "description", limit: 255
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.decimal  "latitude",                precision: 15, scale: 10, default: 0.0
    t.decimal  "longitude",               precision: 15, scale: 10, default: 0.0
  end

  create_table "locations_publications", id: false, force: :cascade do |t|
    t.integer "location_id",    limit: 4
    t.integer "publication_id", limit: 4
  end

  add_index "locations_publications", ["location_id"], name: "index_locations_publications_on_location_id"
  add_index "locations_publications", ["publication_id"], name: "index_locations_publications_on_publication_id"

  create_table "meetings", force: :cascade do |t|
    t.string   "title"
    t.integer  "year"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "description"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "country"
    t.string   "featured_image_file_name"
    t.string   "featured_image_content_type"
    t.integer  "featured_image_file_size"
    t.datetime "featured_image_updated_at"
    t.string   "featured_image_credits"
    t.string   "url"
    t.string   "venue"
  end

  create_table "meetings_organisations", id: false, force: :cascade do |t|
    t.integer "meeting_id"
    t.integer "organisation_id"
  end

  add_index "meetings_organisations", ["meeting_id"], name: "index_meetings_organisations_on_meeting_id"
  add_index "meetings_organisations", ["organisation_id"], name: "index_meetings_organisations_on_organisation_id"

  create_table "meetings_users", id: false, force: :cascade do |t|
    t.integer "meeting_id"
    t.integer "user_id"
  end

  add_index "meetings_users", ["meeting_id"], name: "index_meetings_users_on_meeting_id"
  add_index "meetings_users", ["user_id"], name: "index_meetings_users_on_user_id"

  create_table "observations", force: :cascade do |t|
    t.integer  "observable_id"
    t.string   "observable_type"
    t.integer  "species_id"
    t.integer  "location_id"
    t.integer  "site_id"
    t.integer  "user_id"
    t.integer  "depth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "depth_estimate"
  end

  add_index "observations", ["observable_type", "observable_id"], name: "index_observations_on_observable_type_and_observable_id"

  create_table "organisations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "country",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "organisations_photos", id: false, force: :cascade do |t|
    t.integer "organisation_id"
    t.integer "photo_id"
  end

  add_index "organisations_photos", ["organisation_id"], name: "index_organisations_photos_on_organisation_id"
  add_index "organisations_photos", ["photo_id"], name: "index_organisations_photos_on_photo_id"

  create_table "photos", force: :cascade do |t|
    t.string   "credit"
    t.integer  "photographer_id"
    t.integer  "depth"
    t.boolean  "contains_species"
    t.integer  "location_id"
    t.integer  "site_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "description"
    t.integer  "expedition_id"
    t.boolean  "underwater",         default: false
    t.integer  "post_id"
    t.integer  "meeting_id"
    t.integer  "publication_id"
  end

  create_table "photos_platforms", id: false, force: :cascade do |t|
    t.integer "photo_id"
    t.integer "platform_id"
  end

  add_index "photos_platforms", ["photo_id"], name: "index_photos_platforms_on_photo_id"
  add_index "photos_platforms", ["platform_id"], name: "index_photos_platforms_on_platform_id"

  create_table "photos_users", id: false, force: :cascade do |t|
    t.integer "photo_id"
    t.integer "user_id"
  end

  add_index "photos_users", ["photo_id"], name: "index_photos_users_on_photo_id"
  add_index "photos_users", ["user_id"], name: "index_photos_users_on_user_id"

  create_table "platforms", force: :cascade do |t|
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "platforms_publications", id: false, force: :cascade do |t|
    t.integer "platform_id",    limit: 4
    t.integer "publication_id", limit: 4
  end

  add_index "platforms_publications", ["platform_id"], name: "index_platforms_publications_on_platform_id"
  add_index "platforms_publications", ["publication_id"], name: "index_platforms_publications_on_publication_id"

  create_table "platforms_users", id: false, force: :cascade do |t|
    t.integer "platform_id", limit: 4
    t.integer "user_id",     limit: 4
  end

  add_index "platforms_users", ["platform_id"], name: "index_platforms_users_on_platform_id"
  add_index "platforms_users", ["user_id"], name: "index_platforms_users_on_user_id"

  create_table "posts", force: :cascade do |t|
    t.string   "title",                   limit: 255
    t.text     "content_md",              limit: 65535
    t.text     "content_html",            limit: 65535
    t.boolean  "draft",                   limit: 1,     default: false
    t.integer  "user_id",                 limit: 4
    t.string   "slug",                    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "postable_id"
    t.string   "postable_type"
    t.string   "post_type"
    t.integer  "featured_user_id"
    t.integer  "featured_publication_id"
  end

  add_index "posts", ["postable_type", "postable_id"], name: "index_posts_on_postable_type_and_postable_id"
  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "presentations", force: :cascade do |t|
    t.string   "title"
    t.text     "abstract"
    t.text     "authors"
    t.boolean  "oral"
    t.string   "session"
    t.string   "date"
    t.string   "time"
    t.string   "location"
    t.integer  "poster_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "meeting_id"
    t.string   "pdf_file_name"
    t.string   "pdf_content_type"
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
  end

  create_table "presentations_users", id: false, force: :cascade do |t|
    t.integer "presentation_id", null: false
    t.integer "user_id",         null: false
  end

  create_table "publications", force: :cascade do |t|
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.text     "authors",            limit: 65535
    t.integer  "publication_year",   limit: 4
    t.string   "title",              limit: 255
    t.integer  "journal_id",         limit: 4
    t.string   "issue",              limit: 255
    t.string   "pages",              limit: 255
    t.string   "DOI",                limit: 255
    t.string   "url",                limit: 255
    t.string   "book_title",         limit: 255
    t.string   "book_publisher",     limit: 255
    t.text     "abstract",           limit: 65535
    t.text     "contents",           limit: 65535
    t.string   "volume",             limit: 255
    t.integer  "min_depth",          limit: 4
    t.integer  "max_depth",          limit: 4
    t.boolean  "new_species",        limit: 1
    t.string   "filename",           limit: 255
    t.boolean  "original_data",      limit: 1
    t.boolean  "mesophotic",         limit: 1
    t.string   "pdf_file_name"
    t.string   "pdf_content_type"
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.string   "book_authors"
    t.string   "publication_type"
    t.boolean  "mce",                              default: true
    t.string   "publication_format",               default: "article"
    t.text     "behind_contents"
  end

  create_table "publications_sites", id: false, force: :cascade do |t|
    t.integer "publication_id"
    t.integer "site_id"
  end

  add_index "publications_sites", ["publication_id"], name: "index_publications_sites_on_publication_id"
  add_index "publications_sites", ["site_id"], name: "index_publications_sites_on_site_id"

  create_table "publications_users", id: false, force: :cascade do |t|
    t.integer "publication_id", limit: 4
    t.integer "user_id",        limit: 4
  end

  add_index "publications_users", ["publication_id"], name: "index_publications_users_on_publication_id"
  add_index "publications_users", ["user_id"], name: "index_publications_users_on_user_id"

  create_table "sites", force: :cascade do |t|
    t.string   "site_name",     limit: 255
    t.decimal  "latitude",                  precision: 15, scale: 10, default: 0.0
    t.decimal  "longitude",                 precision: 15, scale: 10, default: 0.0
    t.boolean  "estimated",     limit: 1
    t.integer  "location_id",   limit: 4
    t.string   "siteable_type", limit: 255
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
  end

  add_index "sites", ["siteable_type"], name: "index_sites_on_siteable_type_and_siteable_id"

  create_table "species", force: :cascade do |t|
    t.string   "name"
    t.integer  "focusgroup_id"
    t.string   "fishbase_webid"
    t.string   "aims_webid"
    t.string   "coraltraits_webid"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                        limit: 255,   default: "",    null: false
    t.string   "encrypted_password",           limit: 255,   default: "",    null: false
    t.boolean  "admin",                        limit: 1,     default: false, null: false
    t.boolean  "locked",                       limit: 1,     default: false, null: false
    t.string   "reset_password_token",         limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",           limit: 255
    t.string   "last_sign_in_ip",              limit: 255
    t.string   "confirmation_token",           limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                        limit: 255
    t.string   "first_name",                   limit: 255
    t.string   "last_name",                    limit: 255
    t.string   "phone",                        limit: 255
    t.string   "website",                      limit: 255
    t.string   "alt_website",                  limit: 255
    t.string   "google_scholar",               limit: 255
    t.text     "address",                      limit: 65535
    t.string   "department",                   limit: 255
    t.text     "other_organizations",          limit: 65535
    t.string   "profile_picture_file_name",    limit: 255
    t.string   "profile_picture_content_type", limit: 255
    t.integer  "profile_picture_file_size",    limit: 4
    t.datetime "profile_picture_updated_at"
    t.string   "country",                      limit: 255
    t.text     "research_interests",           limit: 65535
    t.integer  "organisation_id",              limit: 4
    t.string   "twitter",                      limit: 255
    t.boolean  "editor",                                     default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "validations", force: :cascade do |t|
    t.integer  "validatable_id"
    t.string   "validatable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "validations", ["validatable_type", "validatable_id"], name: "index_validations_on_validatable_type_and_validatable_id"

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 1073741823
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "word_exclusions", force: :cascade do |t|
    t.string   "word",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
