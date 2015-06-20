module Analytical
  module Modules
    # Google Universal Analytics
    class Google
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = :head_append
      end

      def print_options(options)
        "{ #{"'cookieDomain': '#{options[:domain]}', " if options[:domain]}
          'allowLinker': #{options[:allow_linker] ? true : false},
          'siteSpeedSampleRate': #{options[:sample_rate] || 0} }"
      end

      def init_javascript(location)
        init_location(location) do
          js = <<-HTML
          <!-- Analytical Init: Google -->
          <script type="text/javascript">
           (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

            ga('create', '#{options[:key]}', 'auto', #{print_options(options)});
            #{"ga('require', 'linkid', 'linkid.js');" if options[:enhanced_link_attribution]}

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

      # http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._addTrans
      # String orderId      Required. Internal unique order id number for this transaction.
      # String affiliation  Optional. Partner or store affiliation (undefined if absent).
      # String total        Required. Total dollar amount of the transaction.
      # String tax          Optional. Tax amount of the transaction.
      # String shipping     Optional. Shipping charge for the transaction.
      # String city         Optional. City to associate with transaction.
      # String state        Optional. State to associate with transaction.
      # String country      Optional. Country to associate with transaction.
      def add_trans(order_id, affiliation=nil, total=nil, tax=nil, shipping=nil, city=nil, state=nil, country=nil)
        data = []
        data << "'#{order_id}'"
        data << "'#{affiliation}'"
        data << "'#{total}'"
        data << "'#{tax}'"
        data << "'#{shipping}'"
        data << "'#{city}'"
        data << "'#{state}'"
        data << "'#{country}'"

        "_gaq.push(['_addTrans', #{data.join(', ')}]);"
      end

      # http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._addItem
      # String orderId  Optional Order ID of the transaction to associate with item.
      # String sku      Required. Item's SKU code.
      # String name     Required. Product name. Required to see data in the product detail report.
      # String category Optional. Product category.
      # String price    Required. Product price.
      # String quantity Required. Purchase quantity.
      def add_item(order_id, sku, name, category, price, quantity)
        data  = "'#{order_id}', '#{sku}', '#{name}', '#{category}', '#{price}', '#{quantity}'"
        "_gaq.push(['_addItem', #{data}]);"
      end

      # http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._trackTrans
      # Sends both the transaction and item data to the Google Analytics server.
      # This method should be used in conjunction with the add_item and add_trans methods.
      def track_trans
        "_gaq.push(['_trackTrans']);"
      end

    end
  end
end
