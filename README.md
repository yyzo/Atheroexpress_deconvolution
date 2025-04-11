# Cellular Deconvolution of Cell-Free RNA in Atherosclerosis
Atherosclerosis involves the formation of plaques in the arterial walls, and their characteristics play a crucial role in determining patient outcomes. Unfortunately, assessing these characteristics usually requires **invasive** plaque removal, a procedure typically performed in **advanced stages** of the disease.

**Circulating cell-free mRNA** (cfRNA) offers a promising, **minimally invasive alternative** for monitoring the disease. By providing a real-time snapshot of gene expression, cfRNA reflects molecular changes in the bloodstream, originating from cell death or active secretion. However, this approach **lacks cellular context**, making it difficult to distinguish between whether the observed gene expression changes are caused by intrinsic transcriptomic alterations, or are the result of shifts in cell type proportions. This question is particularly relevant in atherosclerosis as the different cell types involved heavily influence the disease progression and outcomes. 

To address this, **computational cell type deconvolution** can be applied. By using scRNA-seq data as a reference, this technique predicts the cellular origins of the plasma cfRNA, uncovering the missing cellular context. For this purpose, the deep learning-based approach Scaden<sup>1</sup> was utilised and can be downloaded according to the [developer's guide](https://scaden.readthedocs.io).

## Project Workflow
This project primarily aimed to:
1. Assess the feasibility of deconvoluting the cellular origins of plasma cfRNA in atherosclerosis patients from the Athero-Express biobank<sup>2</sup>.
2. Explore the clinical potential of the predicted cell type proportions.

<picture>
  <img src="https://github.com/yyzo/Atheroexpress_deconvolution/blob/main/docs/project_workflow_github_readme.png" width="500">
</picture>

The Tabula Sapiens was chosen for the deconvolution of bulk circulating cfRNA<sup>3</sup>. Its use as a reference was validated by (A) comparing its performance for atherosclerotic plaque deconvolution with that of a tissue-matched reference. Furthermore, in order to evaluate a baseline performance of the Tabula Sapiens, (B) organ-specific bulk RNA-seq datasets from the Genotype-Tissue Expression Project<sup>4</sup> were deconvoluted. After the validation, (C) the deconvolution of circulating cfRNA was performed and outcomes were analyzed in relation to atherosclerosis symptom severity and risk of major adverse cardiovascular events.

For additional information regarding the data collection, please refer to the corresponding [file](https://github.com/yyzo/Atheroexpress_deconvolution/blob/main/docs/data_collection_metadata.xlsx).

## Setup
Five R Markdown files were created:

|R Markdown file|Purpose|
|--|--|
|01_preprocessing_bulk_RNA| • Remove non-coding genes, genes without HGNC symbols, and lowly expressed genes. <br>• Combine bulk RNA-seq datasets.</br>|
|02_processing_sc_RNA_and_preparation_deconvolution|• Combine cell types from scRNA-seq datasets into major groups. <br>• Match genes in bulk and scRNA-seq datasets.</br>• Format files for cellular deconvolution.
|03_scaden_cellular_deconvolution|• Cellular deconvolution with Scaden, using Bash chunks.|
|04_analysis_cellular_deconvolution|• Validate and visualize obtained outputs. |
|05_clinical_correlations|• Clinical analysis of cellular deconvolution predictions using Athero-Express patient data.<br>• Visualize results from clinical analysis.</br>|

## Directory Structure
For this project, the following directory structure was used to ensure efficiency in the cell type deconvolution process and subsequent analyses.

<details>
  <summary><b>Expand for Directory Structure</b></summary>

  Note: `foo_bar` is used as a placeholder and should be replaced with an identifier specific to the dataset pair used for the cellular deconvolution process.
  
  ```
  main 
  ├─ data
  │  ├─ metadata
  │  ├─ preprocessed_data
  │  ├─ processed_data
  │  │  ├─ scaden_sc_rna_ref_files
  │  │  │  └─ foo_bar
  │  │  │     ├─ foo_bar_celltypes.txt
  │  │  │     └─ foo_bar_counts.txt
  │  │  └─ scaden_bulk_rna_files
  │  │     └─ foo_bar_bulk_data.txt
  │  └─ raw_data
  ├─ functions
  │  ├─ functions_01_R.R
  │  ├─ functions_04_R.R
  │  ├─ functions_05_R.R
  │  ├─ functions_bash.sh
  │  └─ functions_global_R.R
  ├─ output
  │  ├─ export_files # Add subfolders as needed
  │  │  └─ rds_files
  │  ├─ plots # Add subfolders as needed
  │  └─ scaden_predictions
  │     └─ foo_bar
  │        ├─ foo_bar_n1.file # Scaden returns files without extension
  │        ├─ foo_bar_n2.file
  │        ├─ ...
  │        └─ foo_bar_n10.file
  ├─ temp # Folders to store temporary files of the cellular deconvolution process with Scaden
  │  ├─ scaden_simulated_data
  │  └─ scaden_trained_models
  ├─ .gitignore
  README.md
  LICENSE
  ├─ 01_preprocessing_bulk_RNA.Rmd
  ├─ 02_processing_sc_RNA_and_preparation_deconvolution.Rmd
  ├─ 03_scaden_cellular_deconvolution.Rmd
  ├─ 04_analysis_cellular_deconvolution.Rmd
  └─ 05_clinical_correlations.Rmd
  ```
</details>

## License
This project is licensed under the MIT License. See the [LICENSE](https://github.com/yyzo/Atheroexpress_deconvolution/blob/main/LICENSE) file for more details.

## References
1. Menden K, Marouf M, Oller S, Dalmia A, Magruder DS, Kloiber K, Heutink P, Bonn S. Deep learning-based cell composition analysis from tissue expression profiles. Sci Adv. 2020 Jul 22;6(30):eaba2619. doi: 10.1126/sciadv.aba2619. PMID: 32832661; PMCID: PMC7439569.
2. Verhoeven BAN, Velema E, Schoneveld AH, de Vries JPPM, de Bruin P, Seldenrijk CA, et al. Athero-express: differential atherosclerotic plaque expression of mRNA and protein in relation to cardiovascular events and patient characteristics. Rationale and design. Eur J Epidemiol. 2004;19(12):1127–33.
3. Tabula Sapiens Consortium*; Jones RC, Karkanias J, Krasnow MA, Pisco AO, Quake SR, Salzman J, Yosef N, Bulthaup B, Brown P, Harper W, Hemenez M, Ponnusamy R, Salehi A, Sanagavarapu BA, Spallino E, Aaron KA, Concepcion W, Gardner JM, Kelly B, Neidlinger N, Wang Z, Crasta S, Kolluru S, Morri M, Tan SY, Travaglini KJ, Xu C, Alcántara-Hernández M, Almanzar N, Antony J, Beyersdorf B, Burhan D, Calcuttawala K, Carter MM, Chan CKF, Chang CA, Chang S, Colville A, Culver RN, Cvijović I, D'Amato G, Ezran C, Galdos FX, Gillich A, Goodyer WR, Hang Y, Hayashi A, Houshdaran S, Huang X, Irwin JC, Jang S, Juanico JV, Kershner AM, Kim S, Kiss B, Kong W, Kumar ME, Kuo AH, Li B, Loeb GB, Lu WJ, Mantri S, Markovic M, McAlpine PL, de Morree A, Mrouj K, Mukherjee S, Muser T, Neuhöfer P, Nguyen TD, Perez K, Puluca N, Qi Z, Rao P, Raquer-McKay H, Schaum N, Scott B, Seddighzadeh B, Segal J, Sen S, Sikandar S, Spencer SP, Steffes LC, Subramaniam VR, Swarup A, Swift M, Van Treuren W, Trimm E, Veizades S, Vijayakumar S, Vo KC, Vorperian SK, Wang W, Weinstein HNW, Winkler J, Wu TTH, Xie J, Yung AR, Zhang Y, Detweiler AM, Mekonen H, Neff NF, Sit RV, Tan M, Yan J, Bean GR, Charu V, Forgó E, Martin BA, Ozawa MG, Silva O, Toland A, Vemuri VNP, Afik S, Awayan K, Botvinnik OB, Byrne A, Chen M, Dehghannasiri R, Gayoso A, Granados AA, Li Q, Mahmoudabadi G, McGeever A, Olivieri JE, Park M, Ravikumar N, Stanley G, Tan W, Tarashansky AJ, Vanheusden R, Wang P, Wang S, Xing G, Dethlefsen L, Ezran C, Gillich A, Hang Y, Ho PY, Irwin JC, Jang S, Leylek R, Liu S, Maltzman JS, Metzger RJ, Phansalkar R, Sasagawa K, Sinha R, Song H, Swarup A, Trimm E, Veizades S, Wang B, Beachy PA, Clarke MF, Giudice LC, Huang FW, Huang KC, Idoyaga J, Kim SK, Kuo CS, Nguyen P, Rando TA, Red-Horse K, Reiter J, Relman DA, Sonnenburg JL, Wu A, Wu SM, Wyss-Coray T. The Tabula Sapiens: A multiple-organ, single-cell transcriptomic atlas of humans. Science. 2022 May 13;376(6594):eabl4896. doi: 10.1126/science.abl4896. Epub 2022 May 13. PMID: 35549404; PMCID: PMC9812260.
4. GTEx Consortium. The Genotype-Tissue Expression (GTEx) project. Nat Genet. 2013 Jun;45(6):580-5. doi: 10.1038/ng.2653. PMID: 23715323; PMCID: PMC4010069.
