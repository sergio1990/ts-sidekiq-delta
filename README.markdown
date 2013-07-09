Delayed Deltas for Thinking Sphinx (with Sidekiq)
================================================
**This code is HEAVILY borrowed from
[ts-resque-delta](https://github.com/freelancing-god/ts-resque-delta).**

Installation
------------

Add _ts-sidekiq-delta_ to your **Gemfile** file, with the rest of your gem
dependencies:

    gem 'ts-sidekiq-delta', '0.0.3', github: 'sergio1990/ts-sidekiq-delta'

If you're using Rails 3, the rake tasks will automatically be loaded by Rails.

Add the delta property to each `define_index` block:

    define_index delta: ThinkingSphinx::Deltas::SidekiqDelta do
      # ...
    end

If you've never used delta indexes before, you'll want to add the boolean
column named `:delta` to each model's table (note, you must set the `:default`
value to `true`):

    def self.up
      add_column :foos, :delta, :boolean, default: true, null: false
    end

Also, I highly recommend adding a MySQL index to the table of any model using
delta indexes. The Sphinx indexer uses `WHERE table.delta = 1` whenever the
delta indexer runs and `... = 0` whenever the normal indexer runs. Having the
MySQL index on the delta column will generally be a win:

    def self.up
      # ...
      add_index :foos, :delta
    end

Usage
-----
Once you've got it all set up, all you need to do is make sure that the Resque
worker is running. You can do this by specifying the `:ts_delta` queue when
running Resque:

    sidekiq -q ts_delta

Additionally, ts-resque-delta will wrap thinking-sphinx's
`thinking_sphinx:index` and `thinking_sphinx:reindex` tasks with
`thinking_sphinx:lock_deltas` and `thinking_sphinx:unlock_deltas`. This will
prevent the delta indexer from running at the same time as the main indexer.

Finally, ts-sidekiq-delta also provides a rake task called
`thinking_sphinx:smart_index` (or `ts:si` for short). This task, instead of
locking all the delta indexes at once while the main indexer runs, will lock
each delta index independently and sequentially. Thay way, your delta indexer
can run while the main indexer is processing large core indexes.

Very little has been changed in this version from the sources below, so very little credit to me.

Author
-----------------------------------
* [Danny Hawkins](https://github.com/danhawkins)

Contributors (for ts-sidekiq-delta)
___________________________________
* [Sergey Gernyak](https://github.com/sergio1990)

Contributors (for ts-resque-delta)
-----------------------------------
* [Aaron Gibralter](https://github.com/agibralter)
* [Ryan Schlesinger](https://github.com/ryansch) (Locking/`smart_index`)
* [Pat Allan](https://github.com/freelancing-god) (FlyingSphinx support)

Original Contributors (for ts-delayed-delta)
--------------------------------------------
* [Pat Allan](https://github.com/freelancing-god)
* [Ryan Schlesinger](https://github.com/ryansch) (Allowing installs as a plugin)
* [Maximilian Schulz](https://max.jungeelite.de) (Ensuring compatibility with Bundler)
* [Edgars Beigarts](https://github.com/ebeigarts) (Adding intelligent description for tasks)
* [Alexander Simonov](https://simonov.me/) (Explicit table definition)

Copyright
---------
Copyright (c) 2012 Danny Hawkins, and released under an MIT Licence.
