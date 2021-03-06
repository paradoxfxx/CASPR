% A container class to hold workspace analysis information for a single
% workspace ray. NOTE: This class assumes that the ray is
% generated about one of the principle axes.
%
% Author        : Jonathan EDEN
% Created       : 2017
% Description    : This class contains the known information obtained
% through workspace analysis.  That is the pose and any metrics/workspace
% conditions that have been evalauted at that ray.
classdef RayWorkspaceElement < handle
    properties(SetAccess = protected)
        fixed_variables         % The pose for the workspace condition to be evaluated at
        metrics                 % A cell array of different metrics (enum and value)
        conditions              % A cell array of different workspace conditions (enum and intervals)
        free_variable_index     % The index that is left free
        free_variable_range     % The range of values that the free variable takes (1st element should be min and 2nd element max)
        number_dofs             % The number of degrees of freedom associated with this ray
        number_conditions       % The number of conditions
        true_n                  % A vector of true
        zero_n                  % A vector of 0
        % FOR FUTURE EXTENSION
        % CHANGE THE RAY TO BE STORED AS Y=MX+C FORM WHERE STORE THE
        % GRADIENT M (made into a unit vector), THE OFFSET C AND THE
        % RANGE [X_MIN,X_MAX]
    end
    
    methods
        % Constructor for the class
        function wp = RayWorkspaceElement(fixed_variables,n_metrics,n_constraints,free_variable_index,free_variable_range)
            wp.fixed_variables      =   fixed_variables;
            wp.metrics              =   cell(n_metrics,2);
            wp.conditions           =   cell(n_constraints,2);
            wp.free_variable_index  =   free_variable_index;
            wp.free_variable_range  =   free_variable_range;
            wp.number_dofs          =   length(wp.fixed_variables)+1;
            wp.number_conditions    =   size(wp.conditions,1);
            wp.true_n               =   true(wp.number_dofs,1);
            wp.zero_n               =   zeros(wp.number_dofs,1);
            % FOR FUTURE EXTENSION
            % INPUT M, C, AND X
        end
        
        % A function to add the metric information to the point
        function addMetric(obj,metric_type,metric_value,index)
            obj.metrics{index,1} = metric_type;
            obj.metrics{index,2} = metric_value;
        end
        
        % A function to add a new condition to the point
        function addCondition(obj,condition_type,intervals,index)
            obj.conditions{index,1} = condition_type;
            obj.conditions{index,2} = intervals;
        end
        
%         % A function to determine if two rays intersect
%         function [is_intersected,intersection_point] = intersect(obj,obj_range,workspace_ray,workspace_range)
%             % MODIFY FOR INTERSECTION VERSUS UNION
%             if(obj.free_variable_index == workspace_ray.free_variable_index)
%                 % The rays are parallel
%                 if(norm(obj.fixed_variables - workspace_ray.free_variable_index) < 1e-10)
%                     % Covers the case where the same ray is sent
%                     is_intersected = 1;
%                     intersection_point = [];
%                     CASPR_log.Error('Both rays lie on the same line');
%                 else
%                     is_intersected = 0;
%                     intersection_point = [];
%                 end
%             else
%                 % The rays are not parallel
%                 % Determine if the rays are coplanar
%                 numDofs = length(obj.fixed_variables)+1;
%                 ones_vec = true(numDofs,1); 
%                 q_obj = zeros(numDofs,1);
%                 selection_vec_obj = ones_vec; selection_vec_obj(obj.free_variable_index) = false;
%                 q_obj(selection_vec_obj) = obj.fixed_variables; 
%                 fixed_variable_ray = q_obj(workspace_ray.free_variable_index);
%                 q_obj(workspace_ray.free_variable_index) = 0;
%                 q_ray = zeros(numDofs,1);
%                 selection_vec_ray = ones_vec; selection_vec_ray(workspace_ray.free_variable_index) = false;
%                 q_ray(selection_vec_ray) = workspace_ray.fixed_variables; 
%                 fixed_variable_obj = q_ray(obj.free_variable_index);
%                 q_ray(obj.free_variable_index) = 0;
%                 if(norm(q_obj - q_ray) < 1e-10)
%                     % The two rays are coplanar
%                     % Determine if they intersect with overlapping region
%                     numConditionsObj = size(obj.conditions,1);
%                     objRayIntersect = 0; % Does the fixed value of ray intersect with any of the intervals of obj
%                     for i = 1:numConditionsObj
%                         if((obj_range(1) <= fixed_variable_obj)&&(obj_range(2) >= fixed_variable_obj))
%                             objRayIntersect = 1;
%                             break;
%                         end
% %                         intervals = obj.conditions{i,2};
% %                         for j = 1:size(intervals,1)
% %                             if((intervals(j,1) <= fixed_variable_obj)&&(intervals(j,2) >= fixed_variable_obj))
% %                                 objRayIntersect = 1;
% %                                 break; 
% %                             end
% %                         end
% %                         if(objRayIntersect)
% %                             break;
% %                         end
%                     end
%                     numConditionsRay = size(workspace_ray.conditions,1);
%                     rayObjIntersect = 0; % Does the fixed value of obj intersect with any of the intervals of ray
%                     for i = 1:numConditionsRay
%                         if((workspace_range(1) <= fixed_variable_ray)&&(workspace_range(2) >= fixed_variable_ray))
%                             rayObjIntersect = 1;
%                             break;
%                         end
% %                         intervals = workspace_ray.conditions{i,2};
% %                         for j = 1:size(intervals,1)
% %                             if((intervals(j,1) <= fixed_variable_ray)&&(intervals(j,2) >= fixed_variable_ray))
% %                                 rayObjIntersect = 1;
% %                                 break; 
% %                             end
% %                         end
% %                         if(rayObjIntersect)
% %                             break;
% %                         end
%                     end                    
%                     is_intersected = objRayIntersect&rayObjIntersect;
%                     if(is_intersected)
%                         intersection_point = zeros(numDofs,1);
%                         temp_vec = zeros(numDofs,1);
%                         selection_vec_obj = ones_vec; selection_vec_obj(obj.free_variable_index) = false;
%                         intersection_point(selection_vec_obj) = obj.fixed_variables; 
%                         % Now need to fill in the extra point
%                         selection_vec_ray = ones_vec; selection_vec_ray(workspace_ray.free_variable_index) = false;
%                         temp_vec(selection_vec_ray) = workspace_ray.fixed_variables;
%                         intersection_point(obj.free_variable_index) = temp_vec(obj.free_variable_index);
%                     else
%                         intersection_point = [];
%                     end
%                 else
%                     % The two rays are not coplanar
%                     is_intersected = 0;
%                     intersection_point = [];
%                 end
%             end
%             % THIS METHODOLOGY NEEDS TO BE MODIFIED FOR THE TRANSFORMATION
%             % COORDINATES. IN PARTICULAR THE TWO RAYS MAY NOT POSSESS THE
%             % SAME COORDINATES AND THEREFORE THE RAY SHOULD BE DESCRIBED IN
%             % TERMS OF A UNIT GRADIENT, RAY BOUNDS AND OFFSET TERM
%         end
        
        % A function to determine if two rays intersect. This version
        % assumes that the call is made using after parallel and coplanar
        % cases have been eliminated (by the graph index).
        function [is_intersected,intersection_point] = intersect(obj,obj_range,workspace_ray,workspace_range)
            % The rays are not parallel
            % Determine if the rays are coplanar
            q_obj = obj.zero_n;
            selection_vec_obj = obj.true_n; selection_vec_obj(obj.free_variable_index) = false;
            q_obj(selection_vec_obj) = obj.fixed_variables;
            fixed_variable_ray = q_obj(workspace_ray.free_variable_index);
            q_ray = obj.zero_n;
            selection_vec_ray = obj.true_n; selection_vec_ray(workspace_ray.free_variable_index) = false;
            q_ray(selection_vec_ray) = workspace_ray.fixed_variables;
            fixed_variable_obj = q_ray(obj.free_variable_index);
            % The two rays are coplanar
            % Determine if they intersect with overlapping region
            objRayIntersect = 0; % Does the fixed value of ray intersect with any of the intervals of obj
            for i = 1:obj.number_conditions
                if((obj_range(1) <= fixed_variable_obj)&&(obj_range(2) >= fixed_variable_obj))
                    objRayIntersect = 1;
                    break;
                end
            end
            rayObjIntersect = 0; % Does the fixed value of obj intersect with any of the intervals of ray
            for i = 1:workspace_ray.number_conditions
                if((workspace_range(1) <= fixed_variable_ray)&&(workspace_range(2) >= fixed_variable_ray))
                    rayObjIntersect = 1;
                    break;
                end
            end
            is_intersected = objRayIntersect&rayObjIntersect;
            if(is_intersected)
                intersection_point = obj.zero_n;
                temp_vec = obj.zero_n;
                intersection_point(selection_vec_obj) = obj.fixed_variables;
                % Now need to fill in the extra point
                temp_vec(selection_vec_ray) = workspace_ray.fixed_variables;
                intersection_point(obj.free_variable_index) = temp_vec(obj.free_variable_index);
            else
                intersection_point = [];
            end
        end
    end    
end