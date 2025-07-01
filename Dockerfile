FROM mambaorg/micromamba:1.5.0

ENV MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=/opt/conda/bin:/usr/bin:$PATH

SHELL ["bash", "-lc"]
USER root

# Update micromamba and all packages to latest versions
RUN micromamba update --all -y

# Install system dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    ca-certificates \
    curl \
    git \
    unzip \
    zsh \
    bash \
    libcairo2-dev \
    libbz2-dev \
    liblzma-dev \
    wget \
    software-properties-common \
    dirmngr \
    lsb-release \
    gnupg2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install core system packages first (conda-forge only)
RUN micromamba install --channel-priority strict -c conda-forge \
    libstdcxx-ng \
    python=3.10 \
    starship \
    cmake \
    make \
    gcc \
    gxx \
    eza \
    datamash \
    openjdk \
    -y && micromamba clean --all --yes

# Install Jupyter ecosystem (conda-forge only)
RUN micromamba install --channel-priority strict -c conda-forge \
    jupyter \
    jupyterlab \
    notebook \
    ipykernel \
    -y && micromamba clean --all --yes

# Install bioinformatics tools (conda-forge + bioconda)
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    bcftools \
    samtools \
    bedtools \
    tabix \
    -y && micromamba clean --all --yes

# Note: vcftools removed - may be deprecated or have dependency issues

# Install workflow management (conda-forge)
RUN micromamba install --channel-priority strict -c conda-forge \
    snakemake \
    -y && micromamba clean --all --yes

# Install R base and Bioconductor packages (conda-forge + bioconda)
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    r-base \
    bioconductor-deseq2 \
    bioconductor-tximport \
    bioconductor-annotationdbi \
    bioconductor-biomart \
    bioconductor-sva \
    sra-tools \
    entrez-direct \
    -y && micromamba clean --all --yes

# Set LD_LIBRARY_PATH to use conda's libstdc++
ENV LD_LIBRARY_PATH=/opt/conda/lib

# Install ALL Python packages in a single layer
RUN pip3 install --no-cache-dir \
    pandas \
    numpy \
    scipy \
    "kiwisolver<1.4.0" \
    matplotlib \
    seaborn \
    upsetplot \
    radian \
    pygments \
    prompt-toolkit \
    biopython \
    scikit-learn \
    requests \
    beautifulsoup4 \
    xmltodict \
    lxml

# Install ALL R packages in a single layer
RUN R -e "install.packages(c('here', 'data.table', 'metafor', 'tidyverse', 'ggplot2', 'qqman', 'qqplotr', 'reticulate', 'broom', 'readxl', 'writexl', 'knitr', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# Install and configure shell environment in a single layer
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions && \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc && \
    echo 'export DISABLE_AUTO_UPDATE="true"' >> ~/.zshrc && \
    echo 'export DISABLE_UPDATE_PROMPT="true"' >> ~/.zshrc && \
    echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> ~/.zshrc && \
    echo 'if command -v eza > /dev/null; then' >> ~/.zshrc && \
    echo '  alias ls="eza"' >> ~/.zshrc && \
    echo '  alias ll="eza -l"' >> ~/.zshrc && \
    echo '  alias la="eza -la"' >> ~/.zshrc && \
    echo '  alias lt="eza --tree"' >> ~/.zshrc && \
    echo 'fi' >> ~/.zshrc && \
    echo '# Initialize conda' >> ~/.zshrc && \
    echo 'export PATH="/opt/conda/bin:${PATH}"' >> ~/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc && \
    echo 'export PATH="/opt/conda/bin:${PATH}"' >> ~/.bashrc

# Set working directory and copy files in a single layer
WORKDIR /proj
COPY setup.sh /proj/
RUN chmod +x /proj/setup.sh && \
    mkdir -p /proj/data/{raw,metadata,references} \
    /proj/scripts/{differential_expression,download} \
    /proj/logs

# Set environment variables
ENV R_LIBS_USER=/usr/local/lib/R/site-library

# Copy project files and make scripts executable in a single layer
COPY . /proj/
RUN chmod +x /proj/start_jupyter.sh

# Final environment setup
ENTRYPOINT ["zsh", "-l", "-c", "source ~/.zshrc && exec zsh"]
CMD []
