module Analytical
  module Modules
    # Google Universal Analytics
    class Google
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = :head_append
      end

      def init_javascript(location)
        params = "{
          #{"'cookieDomain': '#{options[:domain]}', " if options[:domain]}
          'allowLinker': #{options[:allow_linker] ? true : false},
          'siteSpeedSampleRate': #{options[:sample_rate] || 0} }"

        init_location(location) do
          js = <<-HTML
          <!-- Analytical Init: Google -->
          <script type="text/javascript">
           (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

            ga('create', '#{options[:key]}', 'auto', #{params});
            #{"ga('require', 'linkid', 'linkid.js');" if options[:enhanced_link_attribution]}
            #{"ga('require', 'ecommerce', 'ecommerce.js');" if options[:ecommerce]}
          </script>
          HTML
          js
        end
      end

      def track(*args)
        "ga('send', 'pageview' #{args.empty? ? nil : ", '#{args.first}'"});"
      end

      def event(name, *args)
        data = args.first || {}
        data = data[:value] if data.is_a?(Hash)
        data_string = !data.nil? ? ", #{data}" : ""
        "ga('send', 'event', \"Event\", \"#{name}\"" + data_string + ");"
      end

      # Ecommerce Tracking related
      # https://developers.google.com/analytics/devguides/collection/analyticsjs/ecommerce

      # Add a transaction
      # String transaction_id Required Unique order id for this transaction
      # String affilitiation  Required Affiliation or store name.
      # String total          Required Grand Total.
      # String shipping       Optional Shipping total.
      # Float  tax            Optional Tax
      # String currency       Optional Currency on 3 letter format (USD)
      def add_transaction(transaction_id, total, affiliation = nil, tax = nil,
                            shipping = nil, currency = nil)
        "ga('ecommerce:addTransaction', {
          'id': '#{transaction_id}',
          'affiliation': '#{affiliation}',
          'revenue': '#{total}',
          'shipping': '#{shipping}',
          'tax': '#{tax}',
          'currency': '#{currency}'
        });"
      end

      # Add a item to your transaction (eg: shopping cart)
      # String orderId  Required Transaction ID to associate with item.
      # String name     Required Product name
      # String sku      Optional Item's SKU code
      # String category Optional Product category
      # String price    Optional Product price
      # String quantity Optional Purchase quantity
      def add_item(transaction_id, name, sku = nil, category = nil,
                    price = nil, quantity = nil)
        "ga('ecommerce:addItem', {
          'id': '#{transaction_id}',
          'name': '#{name}',
          'sku': '#{sku}',
          'category': '#{category}',
          'price': '#{price}',
          'quantity': '#{quantity}'
        });"
      end

      # Sends both the transaction and item data to the Google Analytics server.
      # This method should be used in conjunction with the add_item and
      # add_trans methods.
      def track_transaction
        "ga('ecommerce:send');"
      end

      # Clear current transaction
      def clear_transaction
        "ga('ecommerce:clear');"
      end
    end
  end
end
