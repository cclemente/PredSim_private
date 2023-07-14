%% Predictive Simulations of Human Gait

% This script starts the predictive simulation of human movement. The
% required inputs are necessary to start the simulations. Optional inputs,
% if left empty, will be taken from getDefaultSettings.m.

% clear
% close all
% clc
% path to the repository folder
% [pathRepo,~,~] = fileparts(mfilename('fullpath'));
pathRepo = pwd;
% path to the folder that contains the repository folder
[pathRepoFolder,~,~] = fileparts(pathRepo);

max_iter = 4000;

%% Initialize S
pathDefaultSettings = fullfile(pathRepo,'DefaultSettings');
addpath(pathDefaultSettings)

[S] = initializeSettings();
S.misc.main_path = pathRepo;

addpath(fullfile(S.misc.main_path,'VariousFunctions'))

%% Required inputs
% name of the subject
S.subject.name = 'Falisse_et_al_2022';

% path to folder where you want to store the results of the OCP
S.subject.save_folder  = fullfile(pathRepoFolder,'PredSimResults','trackPittoWeights'); %S.subject.name); 

% either choose "quasi-random" or give the path to a .mot file you want to use as initial guess
S.subject.IG_selection = fullfile(S.misc.main_path,'OCP','IK_Guess_Full_GC.mot');
S.subject.IG_selection_gaitCyclePercent = 100;

% S.misc.gaitmotion_type = 'HalfGaitCycle'; 
% S.misc.gaitmotion_type = 'FullGaitCycle'; 

% give the path to the osim model of your subject
osim_path = fullfile(pathRepo,'Subjects',S.subject.name,[S.subject.name '.osim']);

% path to folder with program to create dll files from opensim model (will
% be downloaded automatically if it is not there)
S.Cpp2Dll.PathCpp2Dll_Exe = [pathRepo '\Osim2Dll_exe']; %'C:\GBW_MyPrograms\Osim2Dll_exe';

% Do you want to run the simulation as a batch job (parallel computing toolbox)
S.solver.run_as_batch_job = 0;

%% Optional inputs
% see README.md in the main folder for information about these optional
% inputs.

% Muscle synergies
S.Syn = 1; % 1 = implement muscle synergies
S.NSyn_r = 4;
S.NSyn_l = 4; % if half cycle (symmetric) should be the same as NSyn_l
% (for now, this is not automatic) TO DO
S.weights.Syn_constr = 1e4; % cost function weight for (a-WH)^2
S.SynConstrLower = -0.001;
S.SynConstrUpper = 0.001;
S.misc.gaitmotion_type = 'HalfGaitCycle'; %'FullGaitCycle';
S.sim_name = 'Syn_4R_4L_HalfCycle_trackWeightsPitto2020';

S.Syn_cf_knownSynW = 1; % TO DO: "organise" this a little bit better
% by default, zero?
% S.Syn_cf_knownSynW_r = 0;
% S.Syn_cf_knownSynW_l = 0;  
% load('Pitto2020_4Syn.mat');
% Define weights from Pitto et al. 2020

Pitto2020_4Syn = [0 0.1 0.6 0 0.2 0.95 1 0.15;...
    0.28 0.1 0.4 0 1 0.08 0.05 0;...
    0 0.05 0.15 1 0.01 0.04 0 0.04;...
    0.75 0.8 0.2 0 0 0.03 0.05 1]; % 
S.knownSynW = [Pitto2020_4Syn(:,1),...
    Pitto2020_4Syn(:,2),...
    Pitto2020_4Syn(:,3),Pitto2020_4Syn(:,3),...
    Pitto2020_4Syn(:,4),Pitto2020_4Syn(:,4),...
    Pitto2020_4Syn(:,5),...
    Pitto2020_4Syn(:,6),Pitto2020_4Syn(:,6),...
    Pitto2020_4Syn(:,7),...
    Pitto2020_4Syn(:,8),Pitto2020_4Syn(:,8),Pitto2020_4Syn(:,8)]';
S.knownSynW_idx = [28 31 9 10 7 8 38 32 33 34 1 2 3]; % TO DO: make this more "automatic"
S.weights.knownSynW = 1e2;

% % S.bounds
% S.bounds.a.lower            = ;
% S.bounds.calcn_dist.lower   = ;
% S.bounds.toes_dist.lower    = ;
% S.bounds.tibia_dist.lower   = ;
% S.bounds.SLL.upper          = ;
% S.bounds.SLR.upper          = ;
% S.bounds.dist_trav.lower    = ;
% S.bounds.t_final.upper      = ;
% S.bounds.t_final.lower      = ;
% S.bounds.coordinates        = {'pelvis_tilt',-30,30,'pelvis_list',-30,30};

% % S.metabolicE - metabolic energy
% S.metabolicE.tanh_b = ;
% S.metabolicE.model  = '';

% % S.misc - miscellanious
% S.misc.v_max_s             = ;
% S.misc.visualize_bounds    = 1;
% S.misc.gaitmotion_type     = '';
% S.misc.msk_geom_eq         = '';
% S.misc.poly_order.lower    = ;
% S.misc.poly_order.upper    = ;
% S.misc.msk_geom_bounds      = {{'knee_angle_r','knee_angle_l'},-120,10,'pelvis_tilt',-30,30};
% S.misc.gaitmotion_type = 'FullGaitCycle';

% % S.post_process
S.post_process.make_plot = 0;
% S.post_process.savename  = 'datetime';
% S.post_process.load_prev_opti_vars = 1;
% S.post_process.rerun   = 1;
S.post_process.result_filename = S.sim_name; % 'Falisse_et_al_2022_2Syn_half'; 

% % S.solver
% S.solver.linear_solver  = '';
% S.solver.tol_ipopt      = ;
S.solver.max_iter       = max_iter;
% S.solver.parallel_mode  = '';
% S.solver.N_threads      = 6;
% S.solver.N_meshes       = 100;
% S.solver.par_cluster_name = ;
S.solver.CasADi_path    = 'C:\Users\febre\Documents\MATLAB\casadi-windows-matlabR2016a-v3.5.5'; %'C:\GBW_MyPrograms\casadi_3_5_5';


% % S.subject
% S.subject.mass              = ;
% S.subject.IG_pelvis_y       = ;
% S.subject.adapt_IG_pelvis_y = ;
S.subject.v_pelvis_x_trgt   = 1.33;
% S.subject.IK_Bounds = ;
% S.subject.muscle_strength   = ;
% S.subject.muscle_pass_stiff_shift = {{'soleus_l','soleus_r'},0.9,{'tib_ant_l'},1.1};
% S.subject.muscle_pass_stiff_scale = ;
% S.subject.tendon_stiff_scale      = ;
S.subject.tendon_stiff_scale      = {{'soleus_l','med_gas_l','lat_gas_l','soleus_r','med_gas_r','lat_gas_r'},0.5};
S.subject.mtp_type          = '2022paper';
% S.subject.scale_MT_params         = {{'soleus_l'},'FMo',0.9,{'soleus_l'},'alphao',1.1};
% S.subject.spasticity        = ;
% S.subject.muscle_coordination = ;
S.subject.set_stiffness_coefficient_selected_dofs = {{'mtp_angle_l','mtp_angle_r'},25};
S.subject.set_damping_coefficient_selected_dofs = {{'mtp_angle_l','mtp_angle_r'},2};
% S.subject.set_limit_torque_coefficients_selected_dofs = {{'mtp_angle_l','mtp_angle_r'},[0,0,0,0],[0,0]};

% % S.weights
% S.weights.E         = ;
% S.weights.E_exp     = ;
% S.weights.q_dotdot  = ;
% S.weights.e_arm     = ;
% S.weights.pass_torq = ;
% S.weights.a         = ;
% S.weights.slack_ctrl = ;
% S.weights.pass_torq_includes_damping = ;

% %S.Cpp2Dll: required inputs to convert .osim to .dll
S.Cpp2Dll.compiler = 'Visual Studio 15 2017 Win64'; % 'Visual Studio 17 2022';
% S.Cpp2Dll.export3DSegmentOrigins = ;
S.Cpp2Dll.verbose_mode = 1; % 0 for no outputs from cmake
% S.Cpp2Dll.jointsOrder = ;
% S.Cpp2Dll.coordinatesOrder = ;
        
%% Run predictive simulations
% Check for updates in osim2dll
S.Cpp2Dll.PathCpp2Dll_Exe = InstallOsim2Dll_Exe(S.Cpp2Dll.PathCpp2Dll_Exe);

% % warning wrt pelvis heigt for IG
% if S.subject.adapt_IG_pelvis_y == 0 && S.subject.IG_selection ~= "quasi-random"
%     uiwait(msgbox(["Pelvis height of the IG will not be changed.";"Set S.subject.adapt_IG_pelvis_y to 1 if you want to use the model's pelvis height."],"Warning","warn"));
% end

% Start simulation
if S.solver.run_as_batch_job
    add_pred_sim_to_batch(S,osim_path)
else
    [savename] = run_pred_sim(S,osim_path);
end

%% Plot results
if S.post_process.make_plot && ~S.solver.run_as_batch_job
    % set path to saved result
    result_paths{2} = fullfile(S.subject.save_folder,[savename '.mat']);
    % add path to subfolder with plotting functions
    addpath(fullfile(S.misc.main_path,'PlotFigures'))
    % call plotting script
    run_this_file_to_plot_figures
end

