function J = costLMPC(c,theta,x,xs,N,c0,Q,R,P,T,K,LAMBDA,PSI)
%% Cost function of non-quadratic discrete time LTI
% Inputs:
%   c:      decision variable, from time k to time k+N-1 
%   theta:  decision variable, state and input parametrisation 
%   x:      current state at time k
%   Ts:     controller sample time
%   N:      prediction horizon
%   xref:   state references, constant from time k+1 to k+N
%   u0:     previous controller output at time k-1
%   theta0: previous theta output at time k-1

% Output:
%   J:      objective function cost
%

%% LMPC design parameters

% Set initial plant states, controller output and cost.
xk = x;
ck = c0;

J = 0;
% Loop through each prediction step.
for k=1:N
    % Obtain plant state at next prediction step.
    [xk1,uk]= transitionNominal(xk, ck, K);
    
    % RUNNING COST
    if k < N-1
        % accumulate state tracking cost from x(k+1) to x(k+N).
        J = J + (xk-LAMBDA*theta)'*Q*(xk-LAMBDA*theta);
        % accumulate MV rate of change cost from u(k) to u(k+N-1).
        J = J + (uk-PSI*theta)'*R*(uk-PSI*theta);
    end
    %TERMINAL COST
    if k == N
        J = J + (xk1-LAMBDA*theta)'*P*(xk1-LAMBDA*theta) + (LAMBDA*theta-xs)'*T*(LAMBDA*theta-xs);
    end
    % Update xk and uk for the next prediction step.
    xk = xk1;
    if k<N
        ck = c(:,k+1);
    end
end

