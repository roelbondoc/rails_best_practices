# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/routes file to make sure not use default route that rails generated.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/12-not-use-default-route-if-you-use-restful-design
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check all method call to see if any method call is the same as rails default route.
    #
    #     map.connect ':controller/:action/:id'
    #     map.connect ':controller/:action/:id.:format'
    #
    #   or
    #
    #     match ':controller(/:action(/:id(.:format)))'
    class NotUseDefaultRouteCheck < Check

      def interesting_review_nodes
        [:call]
      end

      def interesting_review_files
        ROUTE_FILE
      end

      # check all method calls, it just compare with rails default route
      #
      # rails2
      #
      #     s(:call, s(:lvar, :map), :connect,
      #       s(:arglist, s(:str, ":controller/:action/:id"))
      #     )
      #     s(:call, s(:lvar, :map), :connect,
      #       s(:arglist, s(:str, ":controller/:action/:id.:format"))
      #     )
      #
      # rails3
      #
      #     s(:call, nil, :match,
      #       s(:arglist, s(:str, ":controller(/:action(/:id(.:format)))"))
      #     )
      def review_start_call(node)
        if s(:call, s(:lvar, :map), :connect, s(:arglist, s(:str, ":controller/:action/:id"))) == node ||
           s(:call, s(:lvar, :map), :connect, s(:arglist, s(:str, ":controller/:action/:id.:format"))) == node ||
           s(:call, nil, :match, s(:arglist, s(:str, ":controller(/:action(/:id(.:format)))"))) == node
          add_error "not use default route"
        end
      end
    end
  end
end
