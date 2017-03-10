%this code is reproduced from DLR with minor edits
%NOTE: this is another good place to work on speeding up the code

%Distorted = the distorted point
%A = the camera matrix
%k1 and k2 = radial distortion parameters

function [undistorted,n_it] = undistort(distorted,A,k1,k2)

% from image pixels to pinhole-centered normalized distances
xd_normalized = distorted(1,:) - A(1,3);
yd_normalized = distorted(2,:) - A(2,3);
yd_normalized = yd_normalized/A(2,2);
xd_normalized = ( (xd_normalized-A(1,2)*yd_normalized) / A(1,1) );
xd_normalized2 = xd_normalized.^2;
yd_normalized2 = yd_normalized.^2;
% we use them as temporary desired undistorted normalized values
xu_normalized = xd_normalized;
yu_normalized = yd_normalized;

% inits
distortion_error = [1;1]; i=1; optim_done=0;

while (~optim_done)
    
    % radial distortion
    r2 = (xu_normalized.^2+yu_normalized.^2);
    d_r = (1+k1*r2+k2*r2.^2);
    
    % distance in normalized coos between desired and actual distorted coos
    dx_normalized = xu_normalized.*d_r - xd_normalized;
    dy_normalized = yu_normalized.*d_r - yd_normalized;
    % Goal: minimize them by refining the undistorted coos.
    % Jacobian of the latter distances w.r.t. the desired undistorted normalized coos:
    dD1dx = d_r + xu_normalized.^2 .* (2*k1+4*k2*r2);
    dD1dy = xu_normalized.*yu_normalized.*(2*k1+4*k2*r2);
    dD2dx = dD1dy;
    dD2dy = d_r + yu_normalized.^2 .* (2*k1 + 4*k2*r2);
    % Linear equation:
    % dxy_normalized + J * delta_xy = [0;0] => delta_xy = -J^(-1)*dxy_normalized
    % J^(-1) = 1/det(J) * [dD2dy -dD1dy; -dD2dx dD1dx]
    det_J = dD2dy.*dD1dx - dD1dy.*dD2dx;
    delta_x = -( dD2dy.*dx_normalized - dD1dy.*dy_normalized)./det_J;
    delta_y = -(-dD2dx.*dx_normalized + dD1dx.*dy_normalized)./det_J;
    % Modifies the undistorted normalized coos.
    xu_normalized = xu_normalized + delta_x;
    yu_normalized = yu_normalized + delta_y;
    
    % This is only necessary for the termination condition:
    r2 = (xu_normalized.^2+yu_normalized.^2); d_r = (1+k1*r2+k2*r2.^2);
    redistorted(1,:) = A(1,1) .* xu_normalized.*d_r + A(1,2) .* yu_normalized.*d_r + A(1,3);
    redistorted(2,:) = A(2,2) .* yu_normalized.*d_r + A(2,3);
    
    % We stop if the (biggest if vector-wise) pixel error is bigger than 0.1.
    if (max((distorted(1,:)-redistorted(1,:)).^2 + ...
            (distorted(2,:)-redistorted(2,:)).^2) < 1e-1) || i>5 % max dis_error < 1e-1 pixels ADDED CONDITION FOR 5 ITERATIONS
        
        optim_done=1;
        
    else
        %disp(i)
        i=i+1; % 2-3 iterations should suffice
        
    end
    
end

% Final undistorted coos in the image.
n_it=i;
undistorted(1,:) = A(1,1) .* xu_normalized + A(1,2) .* yu_normalized + A(1,3);
undistorted(2,:) = A(2,2) .* yu_normalized + A(2,3);